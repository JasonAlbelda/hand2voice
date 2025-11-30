package com.example.hand2voice

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarker
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarkerResult
import java.io.ByteArrayOutputStream
import java.util.Optional

/**
 * Data class to hold extracted keypoints
 */
data class ExtractedFeatures(
    val pose: List<Double>,      // 132 values (33 landmarks × 4: x, y, z, visibility)
    val leftHand: List<Double>,  // 63 values (21 landmarks × 3: x, y, z)
    val rightHand: List<Double>  // 63 values (21 landmarks × 3: x, y, z)
)

/**
 * Handles MediaPipe Holistic processing for sign language feature extraction
 */
class MediaPipeHandler(private val context: Context) {
    
    private val TAG = "MediaPipeHandler"
    
    private var holisticLandmarker: HolisticLandmarker? = null
    private var isReady = false
    
    /**
     * Initialize MediaPipe Holistic Landmarker
     * Downloads and configures the model
     */
    fun initialize(): Boolean {
        return try {
            Log.d(TAG, "Initializing MediaPipe Holistic Landmarker...")
            
            // Configure base options
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("holistic_landmarker.task")
                .build()
            
            // Configure holistic landmarker options
            val options = HolisticLandmarker.HolisticLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .setMinPoseDetectionConfidence(0.5f)
                .setMinPosePresenceConfidence(0.5f)
                .setMinHandLandmarksConfidence(0.5f)
                .build()
            
            // Create holistic landmarker
            holisticLandmarker = HolisticLandmarker.createFromOptions(context, options)
            isReady = true
            
            Log.d(TAG, "MediaPipe Holistic Landmarker initialized successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize MediaPipe", e)
            isReady = false
            false
        }
    }
    
    /**
     * Process a camera frame and extract keypoints
     * 
     * @param imageBytes Raw YUV420 image data from camera
     * @param width Image width
     * @param height Image height
     * @param rotation Camera sensor orientation (0, 90, 180, 270)
     * @return ExtractedFeatures or null if processing failed
     */
    fun processFrame(
        imageBytes: ByteArray,
        width: Int,
        height: Int,
        rotation: Int
    ): ExtractedFeatures? {
        
        if (!isReady || holisticLandmarker == null) {
            Log.w(TAG, "MediaPipe not ready")
            return null
        }
        
        return try {
            // Convert YUV420 to Bitmap
            val bitmap = yuv420ToBitmap(imageBytes, width, height)
            
            // Apply rotation if needed
            val rotatedBitmap = rotateBitmap(bitmap, rotation)
            
            // Convert to MPImage
            val mpImage = BitmapImageBuilder(rotatedBitmap).build()
            
            // Process with MediaPipe - use local variable to avoid smart cast issues
            val landmarker = holisticLandmarker
            if (landmarker != null) {
                val result = landmarker.detect(mpImage)
                // Extract and format keypoints
                extractKeypoints(result)
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Frame processing error", e)
            null
        }
    }
    
    /**
     * Convert YUV420 byte array to Bitmap
     */
    private fun yuv420ToBitmap(data: ByteArray, width: Int, height: Int): Bitmap {
        val yuvImage = YuvImage(data, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 100, out)
        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }
    
    /**
     * Rotate bitmap according to camera orientation
     */
    private fun rotateBitmap(bitmap: Bitmap, rotation: Int): Bitmap {
        if (rotation == 0) return bitmap
        
        val matrix = Matrix()
        matrix.postRotate(rotation.toFloat())
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }
    
    /**
     * Extract keypoints from MediaPipe result
     * Matches the Python implementation format
     */
    private fun extractKeypoints(result: HolisticLandmarkerResult): ExtractedFeatures {
        
        // Extract pose landmarks (33 landmarks × 4 values = 132)
        val pose = mutableListOf<Double>()
        if (result.poseLandmarks().isNotEmpty() ) {
            val poseLandmarks = result.poseLandmarks()
            for (landmark in poseLandmarks) {
                pose.add(landmark.x().toDouble())
                pose.add(landmark.y().toDouble())
                pose.add(landmark.z().toDouble())
                pose.add(0.0) // visibility not available, fill with default value
            }
        } else {
            // Fill with zeros if no landmarks detected
            repeat(33 * 4) { pose.add(0.0) }
        }
        
        // Extract left hand landmarks (21 landmarks × 3 values = 63)
        val leftHand = mutableListOf<Double>()
        if (result.leftHandLandmarks().isNotEmpty()) {
            val leftHandLandmarks = result.leftHandLandmarks()
            for (landmark in leftHandLandmarks) {
                leftHand.add(landmark.x().toDouble())
                leftHand.add(landmark.y().toDouble())
                leftHand.add(landmark.z().toDouble())
            }
        } else {
            // Fill with zeros if no landmarks detected
            repeat(21 * 3) { leftHand.add(0.0) }
        }
        
        // Extract right hand landmarks (21 landmarks × 3 values = 63)
        val rightHand = mutableListOf<Double>()
        if (result.rightHandLandmarks().isNotEmpty()) {
            val rightHandLandmarks = result.rightHandLandmarks()
            for (landmark in rightHandLandmarks) {
                rightHand.add(landmark.x().toDouble())
                rightHand.add(landmark.y().toDouble())
                rightHand.add(landmark.z().toDouble())
            }
        } else {
            // Fill with zeros if no landmarks detected
            repeat(21 * 3) { rightHand.add(0.0) }
        }
        
        Log.d(TAG, "Extracted features - Pose: ${pose.size}, Left: ${leftHand.size}, Right: ${rightHand.size}")
        
        return ExtractedFeatures(
            pose = pose,
            leftHand = leftHand,
            rightHand = rightHand
        )
    }
    
    /**
     * Check if MediaPipe is initialized and ready
     */
    fun isInitialized(): Boolean {
        return isReady && holisticLandmarker != null
    }
    
    /**
     * Release MediaPipe resources
     */
    fun release() {
        try {
            val landmarker = holisticLandmarker
            landmarker?.close()
            holisticLandmarker = null
            isReady = false
            Log.d(TAG, "MediaPipe resources released")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing MediaPipe", e)
        }
    }
}
