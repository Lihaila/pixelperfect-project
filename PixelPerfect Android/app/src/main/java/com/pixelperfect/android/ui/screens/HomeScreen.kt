package com.pixelperfect.android.ui.screens

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.res.painterResource
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.pixelperfect.android.ImageViewModel
import com.pixelperfect.android.ImageProcessingResult
import com.pixelperfect.android.ProcessingOptions
import com.pixelperfect.android.ui.theme.PixelPerfectTheme
import com.pixelperfect.android.ui.theme.ThemeManager
import com.pixelperfect.android.R
import android.graphics.Bitmap

@Composable
fun HomeScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val viewModel: ImageViewModel = viewModel()
    val imageState by viewModel.imageState.collectAsState()
    
    // Initialize ViewModel with context
    LaunchedEffect(context) {
        viewModel.initialize(context)
    }
    
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Header Section
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            elevation = 4.dp
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Logo and title
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.logo),
                        contentDescription = "PixelPerfect Logo",
                        modifier = Modifier.size(32.dp)
                    )
                    
                    Column {
                        Text(
                            text = "PixelPerfect",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colors.primary
                        )
                        Text(
                            text = "Professional Image Optimization",
                            fontSize = 12.sp,
                            color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                        )
                    }
                }
                
                Spacer(modifier = Modifier.weight(1f))
                
                // Theme toggle button
                OutlinedButton(
                    onClick = { ThemeManager.toggleTheme() },
                    modifier = Modifier.size(48.dp),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(4.dp)
                ) {
                    Icon(
                        imageVector = if (ThemeManager.isDarkMode) Icons.Default.LightMode else Icons.Default.DarkMode,
                        contentDescription = if (ThemeManager.isDarkMode) "Switch to Light Mode" else "Switch to Dark Mode",
                        tint = MaterialTheme.colors.primary,
                        modifier = Modifier.size(20.dp)
                    )
                }
                
                Spacer(modifier = Modifier.width(8.dp))
                
                // Status indicator
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .background(Color.Green, CircleShape)
                    )
                    Text(
                        text = "Ready",
                        fontSize = 10.sp,
                        color = MaterialTheme.colors.onSurface.copy(alpha = 0.6f)
                    )
                }
            }
        }
        
        // Main Content
        when {
            imageState.originalImageUri == null -> {
                ImageSelectionCard(
                    onImageSelected = { uri ->
                        viewModel.selectImage(uri)
                    }
                )
            }
            imageState.processedBitmap == null && !imageState.isProcessing -> {
                ImageProcessingSetupCard(
                    imageUri = imageState.originalImageUri!!,
                    options = imageState.processingOptions,
                    onOptionsChanged = { viewModel.updateProcessingOptions(it) },
                    onStartProcessing = { viewModel.processImage() },
                    onNewImage = { viewModel.resetState() }
                )
            }
            imageState.isProcessing -> {
                ProcessingCard()
            }
            else -> {
                ResultsCard(
                    imageUri = imageState.originalImageUri!!,
                    processedBitmap = imageState.processedBitmap!!,
                    result = imageState.processingResult!!,
                    onNewImage = { viewModel.resetState() },
                    onReprocess = { viewModel.processImage() },
                    onSaveImage = { viewModel.saveImage() }
                )
            }
        }
        
        // Error handling
        imageState.error?.let { error ->
            ErrorCard(
                error = error,
                onDismiss = { viewModel.clearError() }
            )
        }
        
        // Success message handling
        imageState.successMessage?.let { message ->
            SuccessCard(
                message = message,
                onDismiss = { viewModel.clearSuccessMessage() }
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Supported Formats
        SupportedFormatsCard()
    }
}

@Composable
fun ImageSelectionCard(onImageSelected: (Uri) -> Unit) {
    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let { onImageSelected(it) }
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = "Add Image",
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colors.primary
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "Select Your Image",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colors.onSurface
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Tap to choose a photo from your gallery",
                fontSize = 14.sp,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f),
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Button(
                onClick = { launcher.launch("image/*") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text(
                    text = "Choose Photo",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
fun ImageProcessingSetupCard(
    imageUri: Uri,
    options: ProcessingOptions,
    onOptionsChanged: (ProcessingOptions) -> Unit,
    onStartProcessing: () -> Unit,
    onNewImage: () -> Unit
) {
    val context = LocalContext.current
    var imageDimensions by remember { mutableStateOf<Pair<Int, Int>?>(null) }
    var imageInfo by remember { mutableStateOf<Triple<String, Long, String>?>(null) } // format, size, mimeType
    
    // Helper function to format file size
    fun formatFileSize(sizeInBytes: Long): String {
        return when {
            sizeInBytes >= 1024 * 1024 -> String.format("%.1f MB", sizeInBytes / (1024.0 * 1024.0))
            sizeInBytes >= 1024 -> String.format("%.1f KB", sizeInBytes / 1024.0)
            else -> "$sizeInBytes bytes"
        }
    }
    
    // Get image dimensions and format when the card appears
    LaunchedEffect(imageUri) {
        try {
            val inputStream = context.contentResolver.openInputStream(imageUri)
            val bitmapOptions = android.graphics.BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            android.graphics.BitmapFactory.decodeStream(inputStream, null, bitmapOptions)
            inputStream?.close()
            
            val width = bitmapOptions.outWidth
            val height = bitmapOptions.outHeight
            
            if (width > 0 && height > 0) {
                imageDimensions = Pair(width, height)
                // Set initial dimensions if not already set
                onOptionsChanged(
                    options.copy(
                        maxWidth = width,
                        maxHeight = height
                    )
                )
            }
            
            // Get file info
            val mimeType = bitmapOptions.outMimeType ?: "image/jpeg"
            val format = when {
                mimeType.contains("png", ignoreCase = true) -> "PNG"
                mimeType.contains("jpeg", ignoreCase = true) || mimeType.contains("jpg", ignoreCase = true) -> "JPEG"
                mimeType.contains("webp", ignoreCase = true) -> "WEBP"
                mimeType.contains("gif", ignoreCase = true) -> "GIF"
                else -> "JPEG"
            }
            
            // Get file size
            val fileSize = try {
                val cursor = context.contentResolver.query(imageUri, null, null, null, null)
                cursor?.use {
                    if (it.moveToFirst()) {
                        val sizeIndex = it.getColumnIndex(android.provider.OpenableColumns.SIZE)
                        if (sizeIndex != -1) it.getLong(sizeIndex) else 0L
                    } else 0L
                } ?: 0L
            } catch (e: Exception) {
                0L
            }
            
            imageInfo = Triple(format, fileSize, mimeType)
            
        } catch (e: Exception) {
            android.util.Log.e("ImageSetup", "Error getting image info: ${e.message}")
        }
    }
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Set Processing Options",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colors.onSurface
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            AsyncImage(
                model = imageUri,
                contentDescription = "Selected Image",
                modifier = Modifier
                    .fillMaxWidth()
                    .height(240.dp),
                contentScale = ContentScale.Crop
            )
            
            // Show image info
            imageDimensions?.let { (width, height) ->
                Text(
                    text = "${width} × ${height} pixels",
                    style = MaterialTheme.typography.caption,
                    color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f),
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
            
            imageInfo?.let { (format, size, _) ->
                if (size > 0) {
                    Text(
                        text = "${formatFileSize(size)} • $format",
                        style = MaterialTheme.typography.caption,
                        color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                    )
                } else {
                    Text(
                        text = "Format: $format",
                        style = MaterialTheme.typography.caption,
                        color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Options and controls (quality, format, dimensions)
            Text("Quality: ${options.quality}", style = MaterialTheme.typography.body2)
            Slider(
                value = options.quality.toFloat(),
                onValueChange = { onOptionsChanged(options.copy(quality = it.toInt())) },
                valueRange = 1f..100f
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text("Output Format:", style = MaterialTheme.typography.body2)
            FormatSegmentedPicker(selectedFormat = options.format, onFormatSelected = {
                onOptionsChanged(options.copy(format = it))
            })
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = options.maxWidth?.toString() ?: "",
                    onValueChange = { width ->
                        val newWidth = width.toIntOrNull()
                        if (options.maintainAspectRatio && newWidth != null && newWidth > 0) {
                            // Calculate height based on width and aspect ratio
                            val aspectRatio = imageDimensions?.let { (w, h) -> w.toFloat() / h.toFloat() } ?: 1f
                            val newHeight = (newWidth / aspectRatio).toInt()
                            onOptionsChanged(options.copy(maxWidth = newWidth, maxHeight = newHeight))
                        } else {
                            onOptionsChanged(options.copy(maxWidth = newWidth))
                        }
                    },
                    label = { Text("Max Width") },
                    modifier = Modifier.weight(1f)
                )
                OutlinedTextField(
                    value = options.maxHeight?.toString() ?: "",
                    onValueChange = { height ->
                        val newHeight = height.toIntOrNull()
                        if (options.maintainAspectRatio && newHeight != null && newHeight > 0) {
                            // Calculate width based on height and aspect ratio
                            val aspectRatio = imageDimensions?.let { (w, h) -> w.toFloat() / h.toFloat() } ?: 1f
                            val newWidth = (newHeight * aspectRatio).toInt()
                            onOptionsChanged(options.copy(maxWidth = newWidth, maxHeight = newHeight))
                        } else {
                            onOptionsChanged(options.copy(maxHeight = newHeight))
                        }
                    },
                    label = { Text("Max Height") },
                    modifier = Modifier.weight(1f)
                )
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Checkbox(
                    checked = options.maintainAspectRatio,
                    onCheckedChange = { onOptionsChanged(options.copy(maintainAspectRatio = it)) }
                )
                Text("Maintain Aspect Ratio")
            }

            Spacer(modifier = Modifier.height(16.dp))
            
            Button(
                onClick = onStartProcessing,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Start Processing")
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            OutlinedButton(
                onClick = onNewImage,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("New Image")
            }
        }
    }
}

@Composable
fun ProcessingCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Processing...",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colors.onSurface
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            CircularProgressIndicator()
        }
    }
}

@Composable
fun ResultsCard(
    imageUri: Uri,
    processedBitmap: Bitmap,
    result: ImageProcessingResult,
    onNewImage: () -> Unit,
    onReprocess: () -> Unit,
    onSaveImage: () -> Unit = {}
) {
    val context = LocalContext.current
    var originalDimensions by remember { mutableStateOf<Pair<Int, Int>?>(null) }
    var originalFormat by remember { mutableStateOf<String?>(null) }
    
    // Get original image dimensions and format
    LaunchedEffect(imageUri) {
        try {
            val inputStream = context.contentResolver.openInputStream(imageUri)
            val options = android.graphics.BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            android.graphics.BitmapFactory.decodeStream(inputStream, null, options)
            inputStream?.close()
            
            val width = options.outWidth
            val height = options.outHeight
            
            if (width > 0 && height > 0) {
                originalDimensions = Pair(width, height)
            }
            
            // Get original format
            val mimeType = options.outMimeType ?: "image/jpeg"
            val format = when {
                mimeType.contains("png", ignoreCase = true) -> "PNG"
                mimeType.contains("jpeg", ignoreCase = true) || mimeType.contains("jpg", ignoreCase = true) -> "JPEG"
                mimeType.contains("webp", ignoreCase = true) -> "WEBP"
                mimeType.contains("gif", ignoreCase = true) -> "GIF"
                else -> "JPEG"
            }
            originalFormat = format
            
        } catch (e: Exception) {
            android.util.Log.e("ResultsCard", "Error getting original info: ${e.message}")
        }
    }
    
    // Helper function to format file size
    fun formatFileSize(sizeInBytes: Long): String {
        return when {
            sizeInBytes >= 1024 * 1024 -> String.format("%.1f MB", sizeInBytes / (1024.0 * 1024.0))
            sizeInBytes >= 1024 -> String.format("%.1f KB", sizeInBytes / 1024.0)
            else -> "$sizeInBytes bytes"
        }
    }
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Processing Results",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colors.onSurface
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Original Image Section
            Text(
                text = "Original Image",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colors.onSurface
            )
            
            AsyncImage(
                model = imageUri,
                contentDescription = "Original Image",
                modifier = Modifier
                    .height(160.dp)
                    .fillMaxWidth(),
                contentScale = ContentScale.Crop
            )
            
            // Original image details
            originalDimensions?.let { (width, height) ->
                Text(
                    text = "${width} × ${height} pixels",
                    style = MaterialTheme.typography.caption,
                    color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                )
            }
            Text(
                text = "Size: ${formatFileSize(result.originalSize)}",
                style = MaterialTheme.typography.caption,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            Text(
                text = "Format: ${originalFormat ?: "Unknown"}",
                style = MaterialTheme.typography.caption,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Optimized Image Section
            Text(
                text = "Optimized Image",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colors.onSurface
            )
            
            Image(
                bitmap = processedBitmap.asImageBitmap(),
                contentDescription = "Processed Image",
                modifier = Modifier
                    .height(160.dp)
                    .fillMaxWidth(),
                contentScale = ContentScale.Crop
            )
            
            // Optimized image details
            Text(
                text = "${processedBitmap.width} × ${processedBitmap.height} pixels",
                style = MaterialTheme.typography.caption,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            Text(
                text = "Size: ${formatFileSize(result.optimizedSize)}",
                style = MaterialTheme.typography.caption,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            Text(
                text = "Format: ${result.format}",
                style = MaterialTheme.typography.caption,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Compression statistics
            Card(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = MaterialTheme.colors.primary.copy(alpha = 0.1f),
                shape = RoundedCornerShape(8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(12.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Compression Statistics",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colors.primary
                    )
                    
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Size Reduction:",
                            fontSize = 11.sp,
                            color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                        )
                        Text(
                            text = "${String.format("%.1f", (1 - result.compressionRatio) * 100)}%",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colors.primary
                        )
                    }
                    
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Space Saved:",
                            fontSize = 11.sp,
                            color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
                        )
                        Text(
                            text = formatFileSize(result.originalSize - result.optimizedSize),
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colors.primary
                        )
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Button(
                onClick = onReprocess,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Reprocess")
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
OutlinedButton(
                onClick = {
                    android.util.Log.d("HomeScreen", "Save Image button clicked")
                    onSaveImage() // Save image to MediaStore
                },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Save Image")
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
                onClick = onNewImage,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("New Image")
            }
        }
    }
}

@Composable
fun ErrorCard(
    error: String,
    onDismiss: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Error",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Red
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = error,
                style = MaterialTheme.typography.body2,
                color = Color.Red,
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Button(
                onClick = onDismiss,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Dismiss")
            }
        }
    }
}

@Composable
fun SuccessCard(
    message: String,
    onDismiss: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Success",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Green
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = message,
                style = MaterialTheme.typography.body2,
                color = Color.Green,
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Button(
                onClick = onDismiss,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Dismiss")
            }
        }
    }
}

@Composable
fun DropdownMenuList(
    selectedFormat: String,
    onFormatSelected: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    Box {
        Button(onClick = { expanded = !expanded }) {
            Text("Format: $selectedFormat")
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            listOf("JPEG", "PNG", "SVG").forEach { format ->
                DropdownMenuItem(onClick = {
                    onFormatSelected(format)
                    expanded = false
                }) {
                    Text(text = format)
                }
            }
        }
    }
}

@Composable
fun FormatSegmentedPicker(
    selectedFormat: String,
    onFormatSelected: (String) -> Unit
) {
    val formats = listOf("JPEG", "PNG", "SVG")
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        formats.forEach { format ->
            val isSelected = selectedFormat == format
            Surface(
                modifier = Modifier
                    .weight(1f)
                    .clickable { onFormatSelected(format) },
                shape = RoundedCornerShape(8.dp),
                color = if (isSelected) {
                    MaterialTheme.colors.primary
                } else {
                    MaterialTheme.colors.surface
                },
                border = ButtonDefaults.outlinedBorder,
                elevation = if (isSelected) 2.dp else 0.dp
            ) {
                Text(
                    text = format,
                    modifier = Modifier.padding(vertical = 12.dp, horizontal = 8.dp),
                    color = if (isSelected) {
                        MaterialTheme.colors.onPrimary
                    } else {
                        MaterialTheme.colors.onSurface
                    },
                    fontSize = 14.sp,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
fun SupportedFormatsCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = 4.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "SUPPORTED FORMATS",
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colors.onSurface.copy(alpha = 0.7f)
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                listOf("JPG", "PNG", "SVG").forEach { format ->
                    Surface(
                        color = MaterialTheme.colors.primary.copy(alpha = 0.1f),
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text(
                            text = format,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colors.primary
                        )
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun HomeScreenPreview() {
    PixelPerfectTheme {
        HomeScreen()
    }
}
