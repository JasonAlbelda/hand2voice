package com.example.hand2voice

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.hand2voice/mediapipe"
    private val TAG = "MainActivity"
    
    private lateinit var mediaPipeHandler: MediaPipeHandler
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize MediaPipe handler
        mediaPipeHandler = MediaPipeHandler(this)
        
        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeMediaPipe" -> {
                    try {
                        val success = mediaPipeHandler.initialize()
                        Log.d(TAG, "MediaPipe initialization: $success")
                        result.success(success)
                    } catch (e: Exception) {
                        Log.e(TAG, "MediaPipe initialization failed", e)
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
                
                "processFrame" -> {
                    try {
                        val imageBytes = call.argument<ByteArray>("imageBytes")
                        val width = call.argument<Int>("width")
                        val height = call.argument<Int>("height")
                        val rotation = call.argument<Int>("rotation")
                        
                        if (imageBytes == null || width == null || height == null || rotation == null) {
                            result.error("INVALID_ARGS", "Missing required arguments", null)
                            return@setMethodCallHandler
                        }
                        
                        val features = mediaPipeHandler.processFrame(imageBytes, width, height, rotation)
                        
                        if (features != null) {
                            val response = hashMapOf<String, Any>(
                                "success" to true,
                                "pose" to features.pose,
                                "leftHand" to features.leftHand,
                                "rightHand" to features.rightHand,
                                "totalFeatures" to (features.pose.size + features.leftHand.size + features.rightHand.size)
                            )
                            result.success(response)
                        } else {
                            result.success(hashMapOf<String, Any>(
                                "success" to false,
                                "pose" to emptyList<Double>(),
                                "leftHand" to emptyList<Double>(),
                                "rightHand" to emptyList<Double>(),
                                "totalFeatures" to 0
                            ))
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Frame processing failed", e)
                        result.error("PROCESS_ERROR", e.message, null)
                    }
                }
                
                "releaseMediaPipe" -> {
                    try {
                        mediaPipeHandler.release()
                        Log.d(TAG, "MediaPipe resources released")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "MediaPipe release failed", e)
                        result.error("RELEASE_ERROR", e.message, null)
                    }
                }
                
                "isInitialized" -> {
                    result.success(mediaPipeHandler.isInitialized())
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mediaPipeHandler.release()
    }
}
