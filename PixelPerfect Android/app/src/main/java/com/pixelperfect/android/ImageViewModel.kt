package com.pixelperfect.android

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*
import android.util.Log

data class ImageState(
    val isProcessing: Boolean = false,
    val originalImageUri: Uri? = null,
    val processedBitmap: Bitmap? = null,
    val processingResult: ImageProcessingResult? = null,
    val processingOptions: ProcessingOptions = ProcessingOptions(),
    val error: String? = null,
    val successMessage: String? = null
)

class ImageViewModel : ViewModel() {
    
    private val _imageState = MutableStateFlow(ImageState())
    val imageState: StateFlow<ImageState> = _imageState.asStateFlow()
    
    private var imageProcessor: ImageProcessor? = null
    private var context: Context? = null
    
    fun initialize(context: Context) {
        this.context = context
        imageProcessor = ImageProcessor(context)
    }
    
    fun selectImage(uri: Uri) {
        _imageState.value = _imageState.value.copy(
            originalImageUri = uri,
            processedBitmap = null,
            processingResult = null,
            error = null
        )
    }
    
    fun updateProcessingOptions(options: ProcessingOptions) {
        _imageState.value = _imageState.value.copy(
            processingOptions = options
        )
    }
    
    fun processImage() {
        val currentState = _imageState.value
        val uri = currentState.originalImageUri
        val processor = imageProcessor
        
        if (uri == null || processor == null) {
            _imageState.value = currentState.copy(
                error = "No image selected or processor not initialized"
            )
            return
        }
        
        _imageState.value = currentState.copy(
            isProcessing = true,
            error = null
        )
        
        viewModelScope.launch {
            try {
                val result = processor.processImage(uri, currentState.processingOptions)
                
                result.fold(
                    onSuccess = { processingResult ->
                        _imageState.value = _imageState.value.copy(
                            isProcessing = false,
                            processedBitmap = processingResult.optimizedBitmap,
                            processingResult = processingResult,
                            error = null
                        )
                    },
                    onFailure = { exception ->
                        _imageState.value = _imageState.value.copy(
                            isProcessing = false,
                            error = "Processing failed: ${exception.message}"
                        )
                    }
                )
            } catch (e: Exception) {
                _imageState.value = _imageState.value.copy(
                    isProcessing = false,
                    error = "Unexpected error: ${e.message}"
                )
            }
        }
    }
    
    fun resetState() {
        _imageState.value = ImageState(
            processingOptions = _imageState.value.processingOptions
        )
    }
    
    fun clearError() {
        _imageState.value = _imageState.value.copy(error = null)
    }
    
    fun clearSuccessMessage() {
        _imageState.value = _imageState.value.copy(successMessage = null)
    }
    
    fun updateQuality(quality: Int) {
        val currentOptions = _imageState.value.processingOptions
        updateProcessingOptions(
            currentOptions.copy(quality = quality.coerceIn(1, 100))
        )
    }
    
    fun updateFormat(format: String) {
        val currentOptions = _imageState.value.processingOptions
        updateProcessingOptions(
            currentOptions.copy(format = format)
        )
    }
    
    fun updateMaxWidth(width: Int?) {
        val currentOptions = _imageState.value.processingOptions
        updateProcessingOptions(
            currentOptions.copy(maxWidth = width)
        )
    }
    
    fun updateMaxHeight(height: Int?) {
        val currentOptions = _imageState.value.processingOptions
        updateProcessingOptions(
            currentOptions.copy(maxHeight = height)
        )
    }
    
    fun updateMaintainAspectRatio(maintain: Boolean) {
        val currentOptions = _imageState.value.processingOptions
        updateProcessingOptions(
            currentOptions.copy(maintainAspectRatio = maintain)
        )
    }
    
    fun saveImage() {
        Log.d("ImageViewModel", "saveImage() called")
        val currentState = _imageState.value
        val bitmap = currentState.processedBitmap
        val result = currentState.processingResult
        val ctx = context
        
        Log.d("ImageViewModel", "Save check - bitmap: ${bitmap != null}, result: ${result != null}, context: ${ctx != null}")
        
        if (bitmap == null || result == null || ctx == null) {
            val errorMsg = "No processed image to save (bitmap: ${bitmap != null}, result: ${result != null}, context: ${ctx != null})"
            Log.e("ImageViewModel", errorMsg)
            _imageState.value = currentState.copy(
                error = errorMsg
            )
            return
        }
        
        Log.d("ImageViewModel", "Starting save process for format: ${result.format}")
        
        viewModelScope.launch {
            try {
                val saved = saveImageToGallery(ctx, bitmap, result.format)
                Log.d("ImageViewModel", "Save result: $saved")
                if (saved) {
                    _imageState.value = currentState.copy(
                        successMessage = "Image saved successfully to gallery!",
                        error = null
                    )
                } else {
                    _imageState.value = currentState.copy(
                        error = "Failed to save image to gallery"
                    )
                }
            } catch (e: Exception) {
                Log.e("ImageViewModel", "Save exception: ${e.message}", e)
                _imageState.value = currentState.copy(
                    error = "Save failed: ${e.message}"
                )
            }
        }
    }
    
    private suspend fun saveImageToGallery(context: Context, bitmap: Bitmap, format: String): Boolean {
        return try {
            Log.d("ImageViewModel", "saveImageToGallery called with format: $format")
            val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val filename = "PixelPerfect_$timestamp"
            
            val mimeType = when (format) {
                "PNG" -> "image/png"
                "SVG" -> "image/svg+xml"
                else -> "image/jpeg"
            }
            
            val extension = when (format) {
                "PNG" -> ".png"
                "SVG" -> ".svg"
                else -> ".jpg"
            }
            
            Log.d("ImageViewModel", "Saving as: $filename$extension (mime: $mimeType)")
            
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, filename + extension)
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/PixelPerfect")
                }
            }
            
            val resolver = context.contentResolver
            val imageUri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            
            Log.d("ImageViewModel", "MediaStore URI: $imageUri")
            
            imageUri?.let { uri ->
                resolver.openOutputStream(uri)?.use { outputStream ->
                    val compressFormat = when (format) {
                        "PNG" -> Bitmap.CompressFormat.PNG
                        else -> Bitmap.CompressFormat.JPEG
                    }
                    Log.d("ImageViewModel", "Compressing bitmap with format: $compressFormat")
                    val compressed = bitmap.compress(compressFormat, 90, outputStream)
                    Log.d("ImageViewModel", "Bitmap compression result: $compressed")
                    compressed
                }
                Log.d("ImageViewModel", "Save completed successfully")
                true
            } ?: run {
                Log.e("ImageViewModel", "Failed to create MediaStore URI")
                false
            }
        } catch (e: Exception) {
            Log.e("ImageViewModel", "Exception in saveImageToGallery: ${e.message}", e)
            false
        }
    }
}
