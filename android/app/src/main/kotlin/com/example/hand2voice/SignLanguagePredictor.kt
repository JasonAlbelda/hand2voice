package com.example.hand2voice

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.tensorflow.lite.Interpreter
import java.io.File
import java.io.FileOutputStream
import org.tensorflow.lite.flex.FlexDelegate

class SignLanguagePredictor(context: Context) {
    private var interpreter: Interpreter? = null
    
    private var mean: FloatArray
    private var std: FloatArray
    private var classes: List<String>

    private val WINDOW_SIZE = 30
    private val FEATURE_DIM = 258
    private val TAG = "FSL_PREDICTOR"

    init {
        Log.d(TAG, "Attempting to load assets...")

        // ---------------------------------------------------------
        // NO TRY-CATCH HERE. 
        // If this fails, we want the Exception to bubble up to MainActivity
        // so we know exactly which file is missing or corrupt.
        // ---------------------------------------------------------

        // 1. Load Model (Copy to Cache Strategy)
        val modelFile = File(context.cacheDir, "fsl_model.tflite")
        // Always overwrite the cache file to ensure we use the latest asset version
        context.assets.open("fsl_model.tflite").use { inputStream ->
            FileOutputStream(modelFile).use { outputStream ->
                inputStream.copyTo(outputStream)
            }
        }
        
        val options = Interpreter.Options()
        options.addDelegate(FlexDelegate()) // <--- ADD THIS LINE
        
        interpreter = Interpreter(modelFile, options)
        interpreter?.resizeInput(0, intArrayOf(1, WINDOW_SIZE, FEATURE_DIM))
        interpreter?.allocateTensors()
        
        Log.d(TAG, "✅ Model Loaded Successfully")

        // 2. Load Classes
        // If classes.txt is missing, this will throw FileNotFoundException
        classes = context.assets.open("classes.txt").bufferedReader().useLines { it.toList() }
        Log.d(TAG, "✅ Loaded ${classes.size} classes")

        // 3. Load Mean/Std using Gson
        val gson = Gson()
        val floatListType = object : TypeToken<List<Float>>() {}.type
        
        // Load Mean
        val meanJson = context.assets.open("mean.json").bufferedReader().use { it.readText() }
        val meanList: List<Float> = gson.fromJson(meanJson, floatListType)
        this.mean = meanList.toFloatArray()

        // Load Std
        val stdJson = context.assets.open("std.json").bufferedReader().use { it.readText() }
        val stdList: List<Float> = gson.fromJson(stdJson, floatListType)
        this.std = stdList.toFloatArray()
        
        Log.d(TAG, "✅ Config Loaded. Mean size: ${mean.size}")
    }

    fun predict(window: List<FloatArray>): Pair<String, Float> {
        // If initialization passed, interpreter cannot be null here.
        // But for safety:
        val tflite = interpreter ?: throw IllegalStateException("Interpreter is null despite successful init")

        // Prepare Input: [1, 30, 258]
        val input = Array(1) { Array(WINDOW_SIZE) { FloatArray(FEATURE_DIM) } }

        for (i in 0 until WINDOW_SIZE) {
            for (j in 0 until FEATURE_DIM) {
                val raw = window[i][j]
                // Safe normalization
                val divisor = if (std[j] == 0f) 1f else std[j]
                input[0][i][j] = (raw - mean[j]) / divisor
            }
        }

        // Output container: [1, NUM_CLASSES]
        val output = Array(1) { FloatArray(classes.size) }

        // Run Inference
        tflite.run(input, output)

        // Get Top Result
        val probs = output[0]
        var maxIdx = -1
        var maxConf = 0f

        for (i in probs.indices) {
            if (probs[i] > maxConf) {
                maxConf = probs[i]
                maxIdx = i
            }
        }

        val label = if (maxIdx != -1 && maxIdx < classes.size) classes[maxIdx] else "Unknown"
        
        if (maxConf > 0.4) {
             Log.d(TAG, "Prediction: $label ($maxConf)")
        }
        
        return Pair(label, maxConf)
    }

    fun close() {
        interpreter?.close()
    }
}
