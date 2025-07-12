package com.pixelperfect.android.ui.theme

import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue

object ThemeManager {
    var isDarkMode by mutableStateOf(false)
        private set
    
    fun toggleTheme() {
        isDarkMode = !isDarkMode
    }
    
    fun setDarkTheme(enabled: Boolean) {
        isDarkMode = enabled
    }
}
