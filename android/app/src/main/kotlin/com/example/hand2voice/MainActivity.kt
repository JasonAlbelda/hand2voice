package com.example.hand2voice

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.hand2voice/mediapipe"
    private val PREDICTION_CHANNEL = "com.example.hand2voice/prediction"
    private val TAG = "MainActivity"
    
    private lateinit var mediaPipeHandler: MediaPipeHandler
    private lateinit var tflitePredictor: TFLitePredictor
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize MediaPipe handler
        mediaPipeHandler = MediaPipeHandler(this)
        tflitePredictor = TFLitePredictor(this)
        
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PREDICTION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadModel" -> {
                    val modelPath = call.argument<String>("modelPath")
                    if (modelPath != null) {
                        val success = tflitePredictor.loadModel(modelPath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Model path is required", null)
                    }
                }
                
                "predict" -> {
                    try {
                        // Dart sends List<List<double>>, Kotlin receives List<List<Double>>
                        val sequence = call.argument<List<List<Double>>>("sequence")
                        
                        if (sequence != null) {
                            val prediction = tflitePredictor.predictSequence(sequence)
                            
                            // Transform the single Pair<Int, Float> into the Map structure your Dart code expects
                            // Dart expects: result['predictions'] (List) and result['confidences'] (List)
                            val response = hashMapOf(
                                "predictions" to listOf(prediction.first),
                                "confidences" to listOf(prediction.second)
                            )
                            result.success(response)
                        } else {
                            result.error("INVALID_ARGS", "Sequence data is null", null)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Prediction error", e)
                        result.error("PREDICT_ERROR", e.message, null)
                    }
                }
                
                "predictFrame" -> {
                    // Helper for single frame prediction if you use it
                    val features = call.argument<List<Double>>("features")
                    if (features != null) {
                        // We wrap the single frame in a list to reuse predictSequence logic
                        val prediction = tflitePredictor.predictSequence(listOf(features))
                        result.success(prediction.first)
                    } else {
                        result.error("INVALID_ARGS", "Features are null", null)
                    }
                }

                "releaseModel" -> {
                    tflitePredictor.release()
                    result.success(true)
                }
                
                else -> result.notImplemented()
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mediaPipeHandler.release()
    }
}