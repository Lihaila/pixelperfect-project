package com.pixelperfect.android

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream

data class ImageProcessingResult(
    val optimizedBitmap: Bitmap,
    val originalSize: Long,
    val optimizedSize: Long,
    val format: String,
    val compressionRatio: Float
)

data class ProcessingOptions(
    val quality: Int = 80,
    val format: String = "JPEG", // JPEG, PNG, SVG
    val maxWidth: Int? = null,
    val maxHeight: Int? = null,
    val maintainAspectRatio: Boolean = true
)

class ImageProcessor(private val context: Context) {
    
    companion object {
        private const val TAG = "ImageProcessor"
        private const val MAX_QUALITY = 100
        private const val MIN_QUALITY = 1
    }
    
    suspend fun processImage(
        imageUri: Uri,
        options: ProcessingOptions = ProcessingOptions()
    ): Result<ImageProcessingResult> {
        return try {
            Log.d(TAG, "Starting image processing with options: $options")
            
            // Load original image
            val originalBitmap = loadBitmapFromUri(imageUri)
                ?: return Result.failure(Exception("Failed to load image"))
            
            val originalSize = getBitmapSize(originalBitmap)
            Log.d(TAG, "Original image size: ${originalBitmap.width}x${originalBitmap.height}, bytes: $originalSize")
            
            // Process image based on format
            val processedBitmap = when (options.format) {
                "JPEG" -> processAsJPEG(originalBitmap, options)
                "PNG" -> processAsPNG(originalBitmap, options)
                "SVG" -> processAsSVG(originalBitmap, options)
                else -> processAsJPEG(originalBitmap, options)
            }
            
            val optimizedSize = getBitmapSize(processedBitmap)
            val compressionRatio = if (originalSize > 0) {
                (originalSize - optimizedSize).toFloat() / originalSize.toFloat()
            } else 0f
            
            Log.d(TAG, "Processing complete. Optimized size: $optimizedSize, compression: ${(compressionRatio * 100).toInt()}%")
            
            Result.success(
                ImageProcessingResult(
                    optimizedBitmap = processedBitmap,
                    originalSize = originalSize,
                    optimizedSize = optimizedSize,
                    format = options.format,
                    compressionRatio = compressionRatio
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Image processing failed", e)
            Result.failure(e)
        }
    }
    
    private fun loadBitmapFromUri(uri: Uri): Bitmap? {
        return try {
            val inputStream: InputStream? = context.contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream?.close()
            
            // Handle image rotation based on EXIF data
            rotateImageIfRequired(bitmap, uri)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load bitmap from URI", e)
            null
        }
    }
    
    private fun rotateImageIfRequired(bitmap: Bitmap, uri: Uri): Bitmap {
        return try {
            val inputStream = context.contentResolver.openInputStream(uri)
            val exif = ExifInterface(inputStream!!)
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )
            
            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> rotateBitmap(bitmap, 90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> rotateBitmap(bitmap, 180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> rotateBitmap(bitmap, 270f)
                else -> bitmap
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to read EXIF data, using original orientation", e)
            bitmap
        }
    }
    
    private fun rotateBitmap(bitmap: Bitmap, degrees: Float): Bitmap {
        val matrix = Matrix()
        matrix.postRotate(degrees)
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }
    
    private fun processAsJPEG(bitmap: Bitmap, options: ProcessingOptions): Bitmap {
        // Resize if needed
        val resizedBitmap = resizeIfNeeded(bitmap, options)
        
        // JPEG compression is applied when saving, return resized bitmap
        return resizedBitmap
    }
    
    private fun processAsPNG(bitmap: Bitmap, options: ProcessingOptions): Bitmap {
        // Resize if needed
        val resizedBitmap = resizeIfNeeded(bitmap, options)
        
        // PNG optimization (can be expanded with PNG-specific optimizations)
        return resizedBitmap
    }
    
    private fun processAsSVG(bitmap: Bitmap, options: ProcessingOptions): Bitmap {
        // For SVG, we'll embed the optimized JPEG as base64
        // This is a simplified approach - real SVG would be vector-based
        return processAsJPEG(bitmap, options.copy(quality = 85))
    }
    
    private fun resizeIfNeeded(bitmap: Bitmap, options: ProcessingOptions): Bitmap {
        val maxWidth = options.maxWidth
        val maxHeight = options.maxHeight
        
        if (maxWidth == null && maxHeight == null) {
            return bitmap
        }
        
        val originalWidth = bitmap.width
        val originalHeight = bitmap.height
        
        var targetWidth = maxWidth ?: originalWidth
        var targetHeight = maxHeight ?: originalHeight
        
        if (options.maintainAspectRatio) {
            val aspectRatio = originalWidth.toFloat() / originalHeight.toFloat()
            
            if (maxWidth != null && maxHeight != null) {
                // Scale to fit within both dimensions
                val widthRatio = maxWidth.toFloat() / originalWidth
                val heightRatio = maxHeight.toFloat() / originalHeight
                val scaleFactor = minOf(widthRatio, heightRatio)
                
                targetWidth = (originalWidth * scaleFactor).toInt()
                targetHeight = (originalHeight * scaleFactor).toInt()
            } else if (maxWidth != null) {
                targetHeight = (maxWidth / aspectRatio).toInt()
            } else if (maxHeight != null) {
                targetWidth = (maxHeight * aspectRatio).toInt()
            }
        }
        
        return if (targetWidth != originalWidth || targetHeight != originalHeight) {
            Log.d(TAG, "Resizing from ${originalWidth}x${originalHeight} to ${targetWidth}x${targetHeight}")
            Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
        } else {
            bitmap
        }
    }
    
    private fun getBitmapSize(bitmap: Bitmap): Long {
        return try {
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
            stream.size().toLong()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to calculate bitmap size", e)
            0L
        }
    }
    
    fun saveBitmapToOutputStream(
        bitmap: Bitmap,
        format: String,
        quality: Int,
        outputStream: ByteArrayOutputStream
    ): Boolean {
        return try {
            val compressFormat = when (format) {
                "PNG" -> Bitmap.CompressFormat.PNG
                "JPEG" -> Bitmap.CompressFormat.JPEG
                "SVG" -> Bitmap.CompressFormat.JPEG // SVG embedding uses JPEG
                else -> Bitmap.CompressFormat.JPEG
            }
            
            val adjustedQuality = quality.coerceIn(MIN_QUALITY, MAX_QUALITY)
            bitmap.compress(compressFormat, adjustedQuality, outputStream)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save bitmap", e)
            false
        }
    }
    
    fun formatFileSize(bytes: Long): String {
        return when {
            bytes < 1024 -> "$bytes B"
            bytes < 1024 * 1024 -> "${bytes / 1024} KB"
            else -> "${bytes / (1024 * 1024)} MB"
        }
    }
}
