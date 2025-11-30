package com.example.hand2voice

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarker

/**
 * Processes video files to extract MediaPipe features from each frame
 */
class VideoProcessor(private val context: Context) {
    
    private val TAG = "VideoProcessor"
    
    /**
     * Extract features from all frames in a video file
     * 
     * @param videoPath Path to video file
     * @param holisticLandmarker Initialized MediaPipe holistic landmarker
     * @param progressCallback Callback for progress updates (frameIndex, totalFrames)
     * @return List of ExtractedFeatures for each frame
     */
    fun extractFeaturesFromVideo(
        videoPath: String,
        holisticLandmarker: HolisticLandmarker,
        progressCallback: ((Int, Int) -> Unit)? = null
    ): List<ExtractedFeatures> {
        
        val features = mutableListOf<ExtractedFeatures>()
        val retriever = MediaMetadataRetriever()
        
        try {
            retriever.setDataSource(videoPath)
            
            // Get video properties
            val durationMs = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLong() ?: 0
            val frameRate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE)?.toFloat() ?: 30f
            
            val totalFrames = ((durationMs / 1000.0) * frameRate).toInt()
            Log.d(TAG, "Processing video: $totalFrames frames at $frameRate fps")
            
            // Extract features from each frame
            for (frameIndex in 0 until totalFrames) {
                val timeUs = (frameIndex * 1_000_000L / frameRate).toLong()
                
                // Get frame as bitmap
                val bitmap = retriever.getFrameAtTime(
                    timeUs,
                    MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                )
                
                if (bitmap != null) {
                    // Process frame with MediaPipe
                    val mpImage = BitmapImageBuilder(bitmap).build()
                    val result = holisticLandmarker.detect(mpImage)
                    
                    // Extract keypoints
                    val frameFeatures = extractKeypointsFromResult(result)
                    features.add(frameFeatures)
                    
                    bitmap.recycle()
                    
                    // Report progress
                    progressCallback?.invoke(frameIndex + 1, totalFrames)
                    
                    if ((frameIndex + 1) % 10 == 0) {
                        Log.d(TAG, "Processed ${frameIndex + 1}/$totalFrames frames")
                    }
                } else {
                    Log.w(TAG, "Failed to extract frame $frameIndex")
                    // Add zero-filled features for missing frames
                    features.add(ExtractedFeatures(
                        pose = List(132) { 0.0 },
                        leftHand = List(63) { 0.0 },
                        rightHand = List(63) { 0.0 }
                    ))
                }
            }
            
            Log.d(TAG, "Video processing complete: ${features.size} frames")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing video", e)
        } finally {
            retriever.release()
        }
        
        return features
    }
    
    /**
     * Extract keypoints from MediaPipe result
     */
    private fun extractKeypointsFromResult(result: com.google.mediapipe.tasks.vision.holisticlandmarker.HolisticLandmarkerResult): ExtractedFeatures {
        
        // Extract pose landmarks (33 landmarks × 4 values = 132)
        val pose = mutableListOf<Double>()
        if (result.poseLandmarks().isNotEmpty()) {
            val poseLandmarks = result.poseLandmarks()
            for (landmark in poseLandmarks) {
                pose.add(landmark.x().toDouble())
                pose.add(landmark.y().toDouble())
                pose.add(landmark.z().toDouble())
                pose.add(0.0) // visibility not available
            }
        } else {
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
            repeat(21 * 3) { rightHand.add(0.0) }
        }
        
        return ExtractedFeatures(
            pose = pose,
            leftHand = leftHand,
            rightHand = rightHand
        )
    }
}
