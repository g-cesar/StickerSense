package com.stickersense.stickersense

import android.content.ClipDescription
import android.content.ContentResolver
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.inputmethodservice.InputMethodService
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputContentInfo
import android.widget.ImageView
import android.widget.Toast
import androidx.core.content.FileProvider
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import java.io.File
import android.graphics.BitmapFactory

class StickerKeyboardService : InputMethodService() {

    private lateinit var recyclerView: RecyclerView
    private val stickers = mutableListOf<String>()

    override fun onCreateInputView(): View {
        val view = layoutInflater.inflate(R.layout.keyboard_view, null)
        recyclerView = view.findViewById(R.id.recyclerView)
        recyclerView.layoutManager = GridLayoutManager(this, 3)
        
        loadStickers()
        
        recyclerView.adapter = StickerAdapter(stickers) { filePath ->
            commitSticker(filePath)
        }
        
        return view
    }

    private fun loadStickers() {
        stickers.clear()
        try {
            // Path to Drift DB. Note: standard path for path_provider on Android
            val dbPath = File(applicationInfo.dataDir, "app_flutter/db.sqlite")
            if (!dbPath.exists()) {
                return
            }

            val db = SQLiteDatabase.openDatabase(dbPath.path, null, SQLiteDatabase.OPEN_READONLY)
            // Query all stickers
            val cursor: Cursor = db.rawQuery("SELECT file_path FROM stickers ORDER BY usage_count DESC", null)
            
            if (cursor.moveToFirst()) {
                do {
                    val path = cursor.getString(0)
                    stickers.add(path)
                } while (cursor.moveToNext())
            }
            cursor.close()
            db.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun commitSticker(filePath: String) {
        val file = File(filePath)
        if (!file.exists()) return

        // We need to share this file using FileProvider so the target app can read it.
        // NOTE: You must configure FileProvider in AndroidManifest to make this work.
        // For MVP, we will try to use the raw path relative to our cache or copy it to a shareable location.
        // However, since we are a keyboard, we should use the Content URI.
        
        try {
            val contentUri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            
            val description = ClipDescription("Sticker", arrayOf("image/png", "image/jpeg"))
            val inputContentInfo = InputContentInfo(
                contentUri,
                description,
                Uri.parse("https://stickersense.com") // Link URI (optional)
            )

            val inputConnection = currentInputConnection
            if (inputConnection != null) {
                val flags = InputConnection.INPUT_CONTENT_GRANT_READ_URI_PERMISSION
                inputConnection.commitContent(inputContentInfo, flags, null)
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Errore invio sticker: ${e.message}", Toast.LENGTH_SHORT).show()
            e.printStackTrace()
        }
    }
}

class StickerAdapter(
    private val items: List<String>,
    private val onClick: (String) -> Unit
) : RecyclerView.Adapter<StickerAdapter.ViewHolder>() {

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val imageView: ImageView = view.findViewById(R.id.imageView)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = android.view.LayoutInflater.from(parent.context)
            .inflate(R.layout.sticker_item, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val path = items[position]
        // Simple Bitmap loading (Main Thread for simplicity in MVP, use Glide/Coil in Prod)
        val bitmap = BitmapFactory.decodeFile(path)
        holder.imageView.setImageBitmap(bitmap)
        holder.imageView.setOnClickListener { onClick(path) }
    }

    override fun getItemCount() = items.size
}
