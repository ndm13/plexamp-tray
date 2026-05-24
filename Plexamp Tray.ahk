#Requires AutoHotkey v2.0
#SingleInstance Force
DetectHiddenWindows(true) 
Persistent 

; --- Configuration ---
TargetWin := "Plexamp ahk_exe Plexamp.exe"
PlexampPath := "C:\Users\" . A_UserName . "\AppData\Local\Programs\Plexamp\Plexamp.exe"

; --- Safety Net ---
OnExit(RestorePlexamp)

; --- Tray Setup ---
A_IconTip := "Plexamp Tray"
Tray := A_TrayMenu
Tray.Delete() 

if FileExist(PlexampPath) {
    try {
        TraySetIcon(PlexampPath, 1)
    }
}

Tray.Add("Toggle Plexamp", TogglePlexamp)
Tray.Add()
Tray.Add("Cover View (200x200)", (*) => ResizePlexamp(200, 200))
Tray.Add("Mini View (200x400)", (*) => ResizePlexamp(200, 400))
Tray.Add("Useful View (350x500)", (*) => ResizePlexamp(350, 500))
Tray.Add()
Tray.Add("Exit Plexamp", KillPlexamp)
Tray.Add("Exit Helper", (*) => ExitApp())
Tray.Default := "Toggle Plexamp"
Tray.ClickCount := 1 

; --- Initial Setup ---
; Try to grab it immediately on launch
if WinExist(TargetWin)
    SetWidgetStyle(WinExist(TargetWin))

; --- Logic ---

TogglePlexamp(*) {
    hwnd := WinExist(TargetWin)
    
    if (hwnd) {
        ; Check if visible (Style 0x10000000)
        if (WinGetStyle(hwnd) & 0x10000000) {
            WinHide(hwnd)
        } else {
            WinShow(hwnd)
            WinActivate(hwnd)
            SetWidgetStyle(hwnd) ; Re-apply style to be safe
        }
    } else {
        if FileExist(PlexampPath) {
            Run(PlexampPath)
            ; Wait specifically for the UI window to appear
            if WinWait(TargetWin, , 5)
                SetWidgetStyle(WinExist(TargetWin))
        }
    }
}

ResizePlexamp(w, h) {
    hwnd := WinExist(TargetWin)
    if (hwnd) {
        try {
            WinShow(hwnd)
            WinActivate(hwnd)
            SetWidgetStyle(hwnd)
            WinMove(,, w, h, hwnd)
        }
    }
}

SetWidgetStyle(hwnd) {
    try {
        ; 1. ADD "ToolWindow" (Hides from Taskbar & Alt-Tab)
        WinSetExStyle("+0x80", hwnd) 
        ; 2. REMOVE "AppWindow" (Forces Taskbar appearance)
        ; Some windows have this set by default, overriding ToolWindow.
        WinSetExStyle("-0x40000", hwnd) 
    }
}

KillPlexamp(*) {
    if WinExist(TargetWin)
        WinClose(TargetWin)
}

RestorePlexamp(*) {
    if WinExist(TargetWin) {
        try {
            ; Restore normal behavior
            WinSetExStyle("-0x80", TargetWin)   ; Remove ToolWindow
            WinSetExStyle("+0x40000", TargetWin) ; Add AppWindow
            WinShow(TargetWin)
        }
    }
}