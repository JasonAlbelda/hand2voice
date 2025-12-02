package com.example.hand2voice

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarker
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarkerResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.hand2voice/mediapipe"
    private val EVENT_CHANNEL_NAME = "com.hand2voice/progress"

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Progress Stream
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
                .setStreamHandler(
                        object : EventChannel.StreamHandler {
                            override fun onListen(
                                    arguments: Any?,
                                    events: EventChannel.EventSink?
                            ) {
                                eventSink = events
                            }
                            override fun onCancel(arguments: Any?) {
                                eventSink = null
                            }
                        }
                )

        // Setup Method Call
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
                .setMethodCallHandler { call, result ->
                    if (call.method == "extractFeatures") {
                        val videoPath = call.argument<String>("videoPath")
                        if (videoPath != null) {
                            CoroutineScope(Dispatchers.IO).launch {
                                try {
                                    val features = processVideo(videoPath)
                                    runOnUiThread { result.success(features) }
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                    runOnUiThread {
                                        result.error("PROCESSING_ERROR", e.message, null)
                                    }
                                }
                            }
                        } else {
                            result.error("INVALID_PATH", "Video path is null", null)
                        }
                    } else {
                        result.notImplemented()
                    }
                }
    }

    private fun processVideo(path: String): List<Map<String, Any>> {
        val retriever = MediaMetadataRetriever()
        var holisticLandmarker: HolisticLandmarker? = null

        try {
            retriever.setDataSource(path)

            // 1. Initialize Holistic Landmarker
            val baseOptions =
                    BaseOptions.builder().setModelAssetPath("holistic_landmarker.task").build()

            val options =
                    HolisticLandmarker.HolisticLandmarkerOptions.builder()
                            .setBaseOptions(baseOptions)
                            .setMinPoseDetectionConfidence(0.5f)
                            .setMinPosePresenceConfidence(0.5f)
                            .setMinHandLandmarksConfidence(0.5f)
                            .setRunningMode(RunningMode.VIDEO) // Crucial for video files
                            .build()

            holisticLandmarker = HolisticLandmarker.createFromOptions(this, options)

            // 2. Prepare Loop
            val durationStr =
                    retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val duration = durationStr?.toLong() ?: 1L
            val step = 133L // Process every 100ms

            val extractedData = mutableListOf<Map<String, Any>>()
            var currentTime = 0L

            // 3. Process Frames
            while (currentTime < duration) {
                // Update Flutter Progress
                val percentage = ((currentTime.toDouble() / duration.toDouble()) * 100).toInt()
                runOnUiThread { eventSink?.success(percentage) }

                val rawBitmap =
                        retriever.getFrameAtTime(
                                currentTime * 1000,
                                MediaMetadataRetriever.OPTION_CLOSEST
                        )

                if (rawBitmap != null) {
                    // 2. SCALE DOWN if image is huge (e.g., 4K or 1080p).
                    // MediaPipe only needs about 640px width for good hand accuracy.
                    // This dramatically speeds up the .detect() call.
                    val scaleWidth = 640
                    val scaleHeight = (rawBitmap.height * (640.0 / rawBitmap.width)).toInt()

                    val scaledBitmap =
                            Bitmap.createScaledBitmap(rawBitmap, scaleWidth, scaleHeight, true)

                    // Ensure ARGB_8888 (Required)
                    val finalBitmap =
                            if (scaledBitmap.config != Bitmap.Config.ARGB_8888) {
                                scaledBitmap.copy(Bitmap.Config.ARGB_8888, true)
                            } else {
                                scaledBitmap
                            }

                    val mpImage = BitmapImageBuilder(finalBitmap).build()

                    // Detect
                    val result = holisticLandmarker.detectForVideo(mpImage, currentTime)

                    // Extract
                    val frameData = extractFeaturesToMap(result)

                    if (frameData.isNotEmpty()) {
                        extractedData.add(
                                mapOf("timestamp" to currentTime, "features" to frameData)
                        )
                    }
                }
                currentTime += step
            }
            return extractedData
        } catch (e: Exception) {
            throw e
        } finally {
            retriever.release()
            holisticLandmarker?.close() // Important: Cleanup
        }
    }

    // Helper to format data for Flutter
    private fun extractFeaturesToMap(result: HolisticLandmarkerResult): Map<String, Any> {
        val data = mutableMapOf<String, Any>()

        // 1. Pose
        if (result.poseLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.poseLandmarks()) {
                list.add(lm.x().toDouble())
                list.add(lm.y().toDouble())
                list.add(lm.z().toDouble())
                val vis = if (lm.visibility().isPresent) lm.visibility().get().toDouble() else 0.0
                list.add(vis)
            }
            data["pose"] = list
        }

        // 2. Left Hand
        if (result.leftHandLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.leftHandLandmarks()) {
                list.add(lm.x().toDouble())
                list.add(lm.y().toDouble())
                list.add(lm.z().toDouble())
            }
            data["left_hand"] = list
        }

        // 3. Right Hand
        if (result.rightHandLandmarks().isNotEmpty()) {
            val list = mutableListOf<Double>()
            for (lm in result.rightHandLandmarks()) {
                list.add(lm.x().toDouble())
                list.add(lm.y().toDouble())
                list.add(lm.z().toDouble())
            }
            data["right_hand"] = list
        }

        return data
    }
}
