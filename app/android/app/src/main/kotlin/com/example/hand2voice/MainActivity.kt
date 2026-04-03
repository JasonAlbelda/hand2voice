package com.example.hand2voice

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarker
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarkerResult
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.ArrayDeque
import kotlin.math.max
import android.util.Log

class MainActivity : FlutterFragmentActivity() {
    private val METHOD_CHANNEL_NAME = "com.hand2voice/mediapipe"
    private val EVENT_CHANNEL_NAME = "com.hand2voice/progress"
    private val SCREEN_SECURITY_CHANNEL = "com.hand2voice/screen_security"
    
    private var eventSink: EventChannel.EventSink? = null
    @Volatile private var isCancelled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Screen Security Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureFlag" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(true)
                }
                "disableSecureFlag" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { eventSink = events }
                override fun onCancel(arguments: Any?) { eventSink = null }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).setMethodCallHandler { call, result ->
            if (call.method == "extractFeatures") {
                val videoPath = call.argument<String>("videoPath")
                isCancelled = false
                if (videoPath != null) {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            // !!! RETURN TYPE CHANGED TO MAP !!!
                            val outputMap = processVideo(videoPath)
                            
                            if (!isCancelled) {
                                runOnUiThread { result.success(outputMap) }
                            } else {
                                runOnUiThread { result.error("CANCELLED", "User cancelled", null) }
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                            runOnUiThread { result.error("ERROR", e.message, null) }
                        }
                    }
                }
            } else if (call.method == "cancelExtraction") {
                isCancelled = true
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    // UPDATED RETURN TYPE: Map<String, Any> instead of List
    private fun processVideo(path: String): Map<String, Any> {
        val retriever = MediaMetadataRetriever()
        var holisticLandmarker: HolisticLandmarker? = null
        var predictor: SignLanguagePredictor? = null
        
        // Output Containers
        val framesForDrawing = mutableListOf<Map<String, Any>>()
        val detectedEvents = mutableListOf<Map<String, Any>>()
        
        try {
            retriever.setDataSource(path)
            
            // 1. Setup Holistic
            val baseOptions = BaseOptions.builder().setModelAssetPath("holistic_landmarker.task").build()
            val options = HolisticLandmarker.HolisticLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setMinPoseDetectionConfidence(0.5f)
                .setMinPosePresenceConfidence(0.5f)
                .setMinHandLandmarksConfidence(0.5f)
                .setRunningMode(RunningMode.VIDEO)
                .build()
            holisticLandmarker = HolisticLandmarker.createFromOptions(this, options)

            // 2. Setup TFLite Predictor
            predictor = SignLanguagePredictor(this)

            // 3. Sliding Window & Logic Stats
            val window = ArrayDeque<FloatArray>()
            val WINDOW_SIZE = 40
            val PERSISTENCE = 5
            val CONFIDENCE_THRESH = 0.8f
            var cooldown = 5
            
            val predictionBuffer = ArrayDeque<String>() // For persistence check
            var currentEventLabel: String? = null
            var currentEventStart = 0.0
            var currentEventConfs = mutableListOf<Float>()

            val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val duration = durationStr?.toLong() ?: 1L
            // Use 33ms to match 30FPS for better prediction accuracy
            val step = 33L 
            var currentTime = 0L
            var frameCount = 0

            while (currentTime < duration) {
                if (isCancelled) break
                
                val percentage = ((currentTime.toDouble() / duration.toDouble()) * 100).toInt()
                runOnUiThread { eventSink?.success(percentage) }

                val rawBitmap = retriever.getFrameAtTime(currentTime * 1000, MediaMetadataRetriever.OPTION_CLOSEST)

                if (rawBitmap != null) {
                    // ARGB Fix + Scale Down for speed (Optional, helps performance)
                    val scaledBitmap = Bitmap.createScaledBitmap(rawBitmap, 640, (rawBitmap.height * (640.0/rawBitmap.width)).toInt(), true)
                    val bitmap = if (scaledBitmap.config != Bitmap.Config.ARGB_8888) {
                        scaledBitmap.copy(Bitmap.Config.ARGB_8888, true)
                    } else {
                        scaledBitmap
                    }
                    val mpImage = BitmapImageBuilder(bitmap).build()
                    val result = holisticLandmarker.detectForVideo(mpImage, currentTime)
                    
                    frameCount++
                    val timestampSec = frameCount / 30.0 // Approx seconds

                    // --- A. Store Drawing Data ---
                    val rawMap = extractFeaturesToMap(result)
                    if (rawMap.isNotEmpty()) {
                        framesForDrawing.add(mapOf(
                            "timestamp" to currentTime,
                            "features" to rawMap
                        ))
                    }

                    // --- B. Prepare TFLite Input (Flat Array) ---
                    val flatFeatures = extractFeaturesFlat(result)
                    
                    // Sliding Window
                    window.add(flatFeatures)
                    if (window.size > WINDOW_SIZE) window.removeFirst()

                    // --- C. Prediction Logic ---
                    var stepLabel: String? = null
                    var stepConf = 0f

                    if (window.size == WINDOW_SIZE) {
                        if (cooldown > 0) {
                            cooldown--
                        } else {
                            val (label, conf) = predictor.predict(window.toList())

                            // LOGGING THE RESULT
                            if (conf > 0.1) {
                                Log.d("FSL_MAIN", "Got: $label ($conf)")
                            }
                            
                            if (conf > CONFIDENCE_THRESH) {
                                predictionBuffer.add(label)
                            } else {
                                predictionBuffer.add("Unknown")
                            }
                            if (predictionBuffer.size > PERSISTENCE) predictionBuffer.removeFirst()

                            // Persistence Check
                            if (predictionBuffer.size == PERSISTENCE) {
                                // Check if all recent predictions are the same and not Unknown
                                val allSame = predictionBuffer.all { it == predictionBuffer.first() }
                                if (allSame && predictionBuffer.first() != "Unknown") {
                                    stepLabel = predictionBuffer.first()
                                    stepConf = conf
                                }
                            }
                        }
                    }

                    // --- D. Event Grouping (Same logic as Python) ---
                    if (stepLabel != null) {
                        if (currentEventLabel == stepLabel) {
                            // Extend existing event
                            currentEventConfs.add(stepConf)
                        } else {
                            // Close old event
                            if (currentEventLabel != null) {
                                val avgConf = currentEventConfs.average()
                                detectedEvents.add(mapOf(
                                    "label" to currentEventLabel!!,
                                    "start_time" to currentEventStart,
                                    "end_time" to timestampSec,
                                    "confidence" to avgConf
                                ))
                            }
                            // Start new event
                            currentEventLabel = stepLabel
                            currentEventStart = timestampSec
                            currentEventConfs.clear()
                            currentEventConfs.add(stepConf)
                            cooldown = 5 // Cooldown frames
                            predictionBuffer.clear()
                        }
                    } else if (currentEventLabel != null && stepLabel == null) {
                        // Prediction stopped, close event
                         val avgConf = currentEventConfs.average()
                         detectedEvents.add(mapOf(
                            "label" to currentEventLabel!!,
                            "start_time" to currentEventStart,
                            "end_time" to timestampSec,
                            "confidence" to avgConf
                        ))
                        currentEventLabel = null
                    }
                }
                currentTime += step
            }
            
            // Close final event if any
            if (currentEventLabel != null) {
                val avgConf = currentEventConfs.average()
                detectedEvents.add(mapOf(
                    "label" to currentEventLabel!!,
                    "start_time" to currentEventStart,
                    "end_time" to (frameCount / 30.0),
                    "confidence" to avgConf
                ))
            }
            
            // RETURN BOTH
            return mapOf(
                "events" to detectedEvents,
                "frames" to framesForDrawing
            )

        } catch (e: Exception) {
            throw e
        } finally {
            retriever.release()
            holisticLandmarker?.close()
            predictor?.close()
        }
    }

    // Extract Map for Drawing (Same as before)
    private fun extractFeaturesToMap(result: HolisticLandmarkerResult): Map<String, Any> {
        val data = mutableMapOf<String, Any>()
        if (result.poseLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.poseLandmarks()) {
                list.add(lm.x().toDouble())
                list.add(lm.y().toDouble())
                list.add(lm.z().toDouble())
                list.add(if (lm.visibility().isPresent) lm.visibility().get().toDouble() else 0.0)
            }
            data["pose"] = list
        }
        if (result.leftHandLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.leftHandLandmarks()) {
                list.add(lm.x().toDouble()); list.add(lm.y().toDouble()); list.add(lm.z().toDouble())
            }
            data["left_hand"] = list
        }
        if (result.rightHandLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.rightHandLandmarks()) {
                list.add(lm.x().toDouble()); list.add(lm.y().toDouble()); list.add(lm.z().toDouble())
            }
            data["right_hand"] = list
        }
        return data
    }

    // Extract Flat Array for TFLite (IMPORTANT: Must match Python logic exactly)
    private fun extractFeaturesFlat(result: HolisticLandmarkerResult): FloatArray {
        // Size: 33*4 + 21*3 + 21*3 = 132 + 63 + 63 = 258
        val flat = FloatArray(258)
        var idx = 0

        // Pose
        if (result.poseLandmarks().isNotEmpty()) {
            for (lm in result.poseLandmarks()) {
                flat[idx++] = lm.x(); flat[idx++] = lm.y(); flat[idx++] = lm.z()
                flat[idx++] = if (lm.visibility().isPresent) lm.visibility().get() else 0f
            }
        } else {
            idx += 132 // Skip
        }

        // Left Hand
        if (result.leftHandLandmarks().isNotEmpty()) {
            for (lm in result.leftHandLandmarks()) {
                flat[idx++] = lm.x(); flat[idx++] = lm.y(); flat[idx++] = lm.z()
            }
        } else {
            idx += 63
        }

        // Right Hand
        if (result.rightHandLandmarks().isNotEmpty()) {
            for (lm in result.rightHandLandmarks()) {
                flat[idx++] = lm.x(); flat[idx++] = lm.y(); flat[idx++] = lm.z()
            }
        } else {
            idx += 63
        }
        
        return flat
    }
}

