package com.example.hand2voice

import android.content.Context
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

/**
 * Handles TensorFlow Lite model loading and inference
 */
class TFLitePredictor(private val context: Context) {
    
    private val TAG = "TFLitePredictor"
    
    private var interpreter: Interpreter? = null
    private var isModelLoaded = false
    
    // Model input/output specs (adjust based on your model)
    private val SEQUENCE_LENGTH = 30  // Number of frames in sequence
    private val FEATURE_DIM = 258     // Pose (132) + Left Hand (63) + Right Hand (63)
    private val NUM_CLASSES = 20     // FSL-105 classes (adjust to your model)
    
    /**
     * Load TFLite model from assets
     */
    fun loadModel(modelPath: String): Boolean {
        return try {
            Log.d(TAG, "Loading model: $modelPath")
            
            val modelFile = loadModelFile(modelPath)
            
            // Configure interpreter options
            val options = Interpreter.Options().apply {
                setNumThreads(4)
                setUseNNAPI(true)  // Use Android Neural Networks API for acceleration
            }
            
            interpreter = Interpreter(modelFile, options)
            isModelLoaded = true
            
            Log.d(TAG, "Model loaded successfully")
            Log.d(TAG, "Input shape: ${interpreter!!.getInputTensor(0).shape().contentToString()}")
            Log.d(TAG, "Output shape: ${interpreter!!.getOutputTensor(0).shape().contentToString()}")
            
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load model", e)
            isModelLoaded = false
            false
        }
    }
    
    /**
     * Load model file from assets
     */
    private fun loadModelFile(modelPath: String): MappedByteBuffer {
        val fileDescriptor = context.assets.openFd(modelPath)
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }
    
    /**
     * Predict action from a sequence of frames
     * 
     * @param sequence List of feature vectors (each 258 dimensions)
     * @return Pair of (predictedClassIndex, confidence)
     */
    fun predictSequence(sequence: List<List<Double>>): Pair<Int, Float> {
        if (!isModelLoaded || interpreter == null) {
            Log.w(TAG, "Model not loaded")
            return Pair(-1, 0f)
        }
        
        if (sequence.isEmpty()) {
            Log.w(TAG, "Empty sequence")
            return Pair(-1, 0f)
        }
        
        try {
            // Prepare input buffer
            val inputBuffer = prepareInputBuffer(sequence)
            
            // Prepare output buffer
            val outputBuffer = Array(1) { FloatArray(NUM_CLASSES) }
            
            // Run inference
            interpreter!!.run(inputBuffer, outputBuffer)
            
            // Get prediction
            val predictions = outputBuffer[0]
            val maxIndex = predictions.indices.maxByOrNull { predictions[it] } ?: -1
            val confidence = if (maxIndex >= 0) predictions[maxIndex] else 0f
            
            Log.d(TAG, "Prediction: class=$maxIndex, confidence=$confidence")
            
            return Pair(maxIndex, confidence)
            
        } catch (e: Exception) {
            Log.e(TAG, "Prediction failed", e)
            return Pair(-1, 0f)
        }
    }
    
    /**
     * Predict multiple segments from a long sequence
     * Useful for continuous sign language recognition
     */
    fun predictContinuous(sequence: List<List<Double>>): List<Pair<Int, Float>> {
        val predictions = mutableListOf<Pair<Int, Float>>()
        
        if (sequence.size < SEQUENCE_LENGTH) {
            // If sequence is shorter than required, pad and predict once
            val prediction = predictSequence(sequence)
            predictions.add(prediction)
            return predictions
        }
        
        // Sliding window approach
        val stride = SEQUENCE_LENGTH / 2  // 50% overlap
        var startIndex = 0
        
        while (startIndex + SEQUENCE_LENGTH <= sequence.size) {
            val segment = sequence.subList(startIndex, startIndex + SEQUENCE_LENGTH)
            val prediction = predictSequence(segment)
            predictions.add(prediction)
            
            startIndex += stride
        }
        
        // Handle remaining frames if any
        if (startIndex < sequence.size) {
            val remainingSegment = sequence.subList(startIndex, sequence.size)
            val prediction = predictSequence(remainingSegment)
            predictions.add(prediction)
        }
        
        return predictions
    }
    
    /**
     * Prepare input buffer from sequence
     * Handles padding/truncation to match model's expected input shape
     */
    private fun prepareInputBuffer(sequence: List<List<Double>>): ByteBuffer {
        val inputSize = SEQUENCE_LENGTH * FEATURE_DIM * 4  // 4 bytes per float
        val buffer = ByteBuffer.allocateDirect(inputSize)
        buffer.order(ByteOrder.nativeOrder())
        
        // Normalize sequence length
        val processedSequence = when {
            sequence.size > SEQUENCE_LENGTH -> {
                // Truncate: take evenly spaced frames
                val indices = (0 until SEQUENCE_LENGTH).map { i ->
                    (i * sequence.size / SEQUENCE_LENGTH).coerceIn(0, sequence.size - 1)
                }
                indices.map { sequence[it] }
            }
            sequence.size < SEQUENCE_LENGTH -> {
                // Pad with zeros
                sequence + List(SEQUENCE_LENGTH - sequence.size) { List(FEATURE_DIM) { 0.0 } }
            }
            else -> sequence
        }
        
        // Fill buffer
        for (frame in processedSequence) {
            for (value in frame) {
                buffer.putFloat(value.toFloat())
            }
        }
        
        buffer.rewind()
        return buffer
    }
    
    /**
     * Check if model is loaded
     */
    fun isLoaded(): Boolean = isModelLoaded
    
    /**
     * Release model resources
     */
    fun release() {
        try {
            interpreter?.close()
            interpreter = null
            isModelLoaded = false
            Log.d(TAG, "Model resources released")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing model", e)
        }
    }
}