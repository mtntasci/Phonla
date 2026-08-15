package com.alafteknoloji.photon.services

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.exifinterface.media.ExifInterface
import com.alafteknoloji.photon.models.LoadedPhoto
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Service for securely loading and non-destructively exporting photos via Android MediaStore.
 * 100% Parity with iOS PhotoLibraryService.swift.
 */
class PhotoLibraryService(private val context: Context) {

    /**
     * Loads a photo from URI and creates both original and downsampled preview bitmaps.
     */
    suspend fun loadPhoto(uri: Uri): Result<LoadedPhoto> = withContext(Dispatchers.IO) {
        try {
            val contentResolver = context.contentResolver

            // 1. Decode bounds
            var inputStream: InputStream? = contentResolver.openInputStream(uri)
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeStream(inputStream, null, options)
            inputStream?.close()

            val origWidth = options.outWidth
            val origHeight = options.outHeight

            // 2. Decode full original bitmap
            val decodeOptions = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
            }
            inputStream = contentResolver.openInputStream(uri)
            val decodedBitmap = BitmapFactory.decodeStream(inputStream, null, decodeOptions)
                ?: throw IllegalStateException("Görsel çözümlenemedi")
            inputStream?.close()

            // 3. Fix EXIF orientation if needed
            val orientedBitmap = fixOrientation(uri, decodedBitmap)

            // 4. Create optimized preview bitmap (max dimension 1600px for 60fps live canvas)
            val maxPreviewDim = 1600f
            val maxDim = maxOf(orientedBitmap.width, orientedBitmap.height)
            val previewBitmap = if (maxDim > maxPreviewDim) {
                val scale = maxPreviewDim / maxDim
                Bitmap.createScaledBitmap(
                    orientedBitmap,
                    (orientedBitmap.width * scale).toInt(),
                    (orientedBitmap.height * scale).toInt(),
                    true
                )
            } else {
                orientedBitmap
            }

            Result.success(
                LoadedPhoto(
                    sourceUri = uri,
                    originalBitmap = orientedBitmap,
                    previewBitmap = previewBitmap,
                    width = orientedBitmap.width,
                    height = orientedBitmap.height,
                    filename = "photon_${System.currentTimeMillis()}.jpg"
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Non-destructively exports the rendered bitmap to the user's Gallery (Pictures/Photon) as a new asset.
     */
    suspend fun saveToGallery(bitmap: Bitmap): Result<Uri> = withContext(Dispatchers.IO) {
        try {
            val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val filename = "PHOTONLA_$timeStamp.jpg"

            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/Photonla")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
            }

            val resolver = context.contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                ?: throw IllegalStateException("MediaStore kaydı oluşturulamadı")

            resolver.openOutputStream(uri)?.use { stream ->
                val success = bitmap.compress(Bitmap.CompressFormat.JPEG, 98, stream)
                if (!success) throw IllegalStateException("Görsel sıkıştırılamadı")
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, contentValues, null, null)
            }

            Result.success(uri)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun fixOrientation(uri: Uri, bitmap: Bitmap): Bitmap {
        return try {
            val inputStream = context.contentResolver.openInputStream(uri) ?: return bitmap
            val exif = ExifInterface(inputStream)
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )
            inputStream.close()

            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
                ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
                ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.postScale(1f, -1f)
                else -> return bitmap
            }

            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (e: Exception) {
            bitmap
        }
    }
}
