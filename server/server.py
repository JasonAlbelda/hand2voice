import os
import cv2
import numpy as np
import mediapipe as mp
import tensorflow as tf  # or 'import tflite_runtime.interpreter as tflite'
from flask import Flask, request, jsonify
import threading
from collections import deque, Counter
import json

# ================= CONFIGURATION =================
SHOW_PREVIEW = False
MODEL_DIR = "assets"
WINDOW_SIZE = 30
CONFIDENCE_THRESHOLD = 0.7
PERSISTENCE_THRESHOLD = 5
COOLDOWN_FRAMES = 5
# =================================================

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024

# ==============================================================================
# 1. TFLITE PREDICTOR CLASS
# ==============================================================================


class SignLanguagePredictor:
    def __init__(self, model_dir):
        model_path = os.path.join(model_dir, "fsl_model.tflite")
        mean_path = os.path.join(model_dir, "mean.npy")
        std_path = os.path.join(model_dir, "std.npy")
        classes_path = os.path.join(model_dir, "classes.npy")
        filipino_labels_path = os.path.join(model_dir, "filipino_labels.json")

        print("⏳ Loading TFLite Model...")

        # Load Params
        self.mean = np.load(mean_path)
        self.std = np.load(std_path)
        self.classes = np.load(classes_path, allow_pickle=True)
        
        # Load Filipino labels mapping
        self.filipino_labels = {}
        if os.path.exists(filipino_labels_path):
            with open(filipino_labels_path, 'r', encoding='utf-8') as f:
                self.filipino_labels = json.load(f)
            print(f"✅ Loaded Filipino labels: {len(self.filipino_labels)} entries")
        else:
            print("⚠️ Filipino labels file not found, using default classes")

        # Load TFLite
        try:
            self.interpreter = tf.lite.Interpreter(model_path=model_path)
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()

            # Resize input to match window size (1, 30, 258)
            self.interpreter.resize_tensor_input(
                self.input_details[0]['index'],
                [1, WINDOW_SIZE, 258]
            )
            self.interpreter.allocate_tensors()
            print(f"✅ TFLite Model Loaded! Classes: {len(self.classes)}")
        except Exception as e:
            print(f"❌ Failed to load TFLite: {e}")
            raise e

    def predict(self, feature_window):
        # Normalize
        norm_seq = (feature_window - self.mean) / self.std
        # Add Batch Dim
        input_data = np.expand_dims(norm_seq, axis=0).astype(np.float32)

        # Inference
        self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
        self.interpreter.invoke()
        output_data = self.interpreter.get_tensor(
            self.output_details[0]['index'])[0]

        best_idx = np.argmax(output_data)
        confidence = output_data[best_idx]
        return best_idx, confidence

    def get_label(self, idx):
        if 0 <= idx < len(self.classes):
            # Try to get Filipino label first
            if self.filipino_labels and str(idx) in self.filipino_labels:
                return self.filipino_labels[str(idx)]
            # Fallback to original class name
            return str(self.classes[idx])
        return "Unknown"

# ==============================================================================
# 2. SERVER & MEDIAPIPE SETUP
# ==============================================================================


# Global Instances
predictor = None
try:
    predictor = SignLanguagePredictor(MODEL_DIR)
except Exception as e:
    print(f"⚠️ Warning: Model not loaded. {e}")

mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils
holistic = mp_holistic.Holistic(
    static_image_mode=False,
    model_complexity=1,
    smooth_landmarks=True,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

jobs = {}
jobs_lock = threading.Lock()


def extract_features_flat(results):
    """Extracts flat array for Prediction (258,)"""
    if results.pose_landmarks:
        pose = np.array([[lm.x, lm.y, lm.z, lm.visibility]
                        for lm in results.pose_landmarks.landmark]).flatten()
    else:
        pose = np.zeros(33 * 4)

    if results.left_hand_landmarks:
        lh = np.array([[lm.x, lm.y, lm.z]
                      for lm in results.left_hand_landmarks.landmark]).flatten()
    else:
        lh = np.zeros(21 * 3)

    if results.right_hand_landmarks:
        rh = np.array([[lm.x, lm.y, lm.z]
                      for lm in results.right_hand_landmarks.landmark]).flatten()
    else:
        rh = np.zeros(21 * 3)

    return np.concatenate([pose, lh, rh])


def extract_features_map(results):
    """Extracts Dictionary for Mobile Drawing"""
    frame_features = {}
    if results.pose_landmarks:
        frame_features['pose'] = [val for lm in results.pose_landmarks.landmark for val in (
            lm.x, lm.y, lm.z, lm.visibility)]
    if results.left_hand_landmarks:
        frame_features['left_hand'] = [
            val for lm in results.left_hand_landmarks.landmark for val in (lm.x, lm.y, lm.z)]
    if results.right_hand_landmarks:
        frame_features['right_hand'] = [
            val for lm in results.right_hand_landmarks.landmark for val in (lm.x, lm.y, lm.z)]
    return frame_features


def background_processing(filepath, request_id):
    print(f"⏳ Processing started for {request_id}")

    # Sliding Window Logic
    input_buffer = deque(maxlen=WINDOW_SIZE)
    predictions_buffer = deque(maxlen=PERSISTENCE_THRESHOLD)
    cooldown = 0

    # Results
    detected_events = []
    frames_for_drawing = []  # To send back to app

    cap = cv2.VideoCapture(filepath)
    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps == 0:
        fps = 30
    frame_count = 0

    try:
        while cap.isOpened():
            with jobs_lock:
                if request_id not in jobs or jobs[request_id]['status'] == 'cancelled':
                    break

            success, frame = cap.read()
            if not success:
                break

            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = holistic.process(image)
            frame_count += 1
            # ms for drawing sync
            timestamp = int(cap.get(cv2.CAP_PROP_POS_MSEC))
            timestamp_sec = frame_count / fps  # seconds for event logging

            # 1. Store Raw Features for App Drawing
            raw_map = extract_features_map(results)
            if raw_map:
                frames_for_drawing.append({
                    "timestamp": timestamp,
                    "features": raw_map
                })

            # 2. Prediction Logic
            current_prediction_text = None
            if predictor:
                feats = extract_features_flat(results)
                input_buffer.append(feats)

                if len(input_buffer) == WINDOW_SIZE:
                    if cooldown > 0:
                        cooldown -= 1
                    else:
                        best_idx, confidence = predictor.predict(
                            np.array(list(input_buffer)))

                        if confidence > CONFIDENCE_THRESHOLD:
                            predictions_buffer.append(best_idx)
                        else:
                            predictions_buffer.append(-1)

                        # Persistence Check
                        if len(predictions_buffer) == PERSISTENCE_THRESHOLD:
                            counts = Counter(predictions_buffer)
                            most_common_id, frequency = counts.most_common(1)[
                                0]

                            if most_common_id != -1 and frequency == PERSISTENCE_THRESHOLD:
                                label = predictor.get_label(most_common_id)
                                current_prediction_text = label

                                # Create Event
                                event = {
                                    "label": label,
                                    "start_time": float(f"{timestamp_sec:.2f}"),
                                    # Give it a 1.5s duration visual
                                    "end_time": float(f"{timestamp_sec + 1.5:.2f}"),
                                    "confidence": float(f"{confidence:.4f}")
                                }
                                detected_events.append(event)
                                cooldown = COOLDOWN_FRAMES
                                predictions_buffer.clear()

            # 3. Preview (Optional)
            if SHOW_PREVIEW:
                debug_image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
                if results.left_hand_landmarks:
                    mp_drawing.draw_landmarks(
                        debug_image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
                if results.right_hand_landmarks:
                    mp_drawing.draw_landmarks(
                        debug_image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
                if current_prediction_text:
                    cv2.putText(debug_image, f"Sign: {current_prediction_text}", (21, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                cv2.imshow(f"Processing {request_id}", debug_image)
                cv2.waitKey(1)

        cap.release()
        if SHOW_PREVIEW:
            cv2.destroyWindow(f"Processing {request_id}")

        # 4. Save Final Result
        with jobs_lock:
            jobs[request_id] = {
                "status": "done",
                "events": detected_events,
                "frames": frames_for_drawing
            }
        print(f"✅ Job {request_id} completed. Events: {len(detected_events)}")

    except Exception as e:
        print(f"❌ Error: {e}")
        with jobs_lock:
            jobs[request_id] = {"status": "failed", "error": str(e)}
    finally:
        if os.path.exists(filepath):
            os.remove(filepath)

# ==============================================================================
# 3. ROUTES (Unchanged)
# ==============================================================================


@app.route('/process/<request_id>', methods=['POST'])
def start_processing(request_id):
    if 'video' not in request.files:
        return jsonify({"error": "No video"}), 400
    file = request.files['video']
    temp_path = f"temp_{request_id}.mp4"
    file.save(temp_path)
    with jobs_lock:
        jobs[request_id] = {"status": "processing"}
    thread = threading.Thread(
        target=background_processing, args=(temp_path, request_id))
    thread.daemon = True
    thread.start()
    return jsonify({"message": "Processing started."}), 202


@app.route('/status/<request_id>', methods=['GET'])
def check_status(request_id):
    with jobs_lock:
        job = jobs.get(request_id)
    if not job:
        return jsonify({"status": "not_found"}), 404
    return jsonify(job)


@app.route('/cancel/<request_id>', methods=['POST'])
def cancel_job(request_id):
    with jobs_lock:
        if request_id in jobs:
            jobs[request_id]['status'] = 'cancelled'
    return jsonify({"status": "cancelled"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
