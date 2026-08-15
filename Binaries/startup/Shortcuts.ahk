; Hey
; This is SuperKingCrimson's coding shortcuts
; feel free to change this it uses MIT license
; to make this run on startup (on windows):
	; type Windows + R
	; type in shell:startup
	; paste this file in
; Enjoy!
#Requires AutoHotkey v2.0
#SingleInstance force
InstallKeybdHook(True)

; Virtual Desktops (make sure to get VD.ahk)
DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")

; Function to focus a specific window handle (HWND)
FocusFlashingWindow(hwnd) {
    if WinExist("ahk_id " hwnd) {
        ; Prevent stealing focus if you are actively using a full-screen app/game
        Style := WinGetStyle("ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)
    }
}

; Function to scan all open windows for the flashing attribute
ScanAndFocusFlashing() {
	WindowList := WinGetList()
	for hwnd in WindowList {
		try {
			Style := WinGetStyle("ahk_id " hwnd)
			; 0x00040000 corresponds to WS_EX_FLASH (demanding attention)
			if (Style & 0x00040000) {
				FocusFlashingWindow(hwnd)
				break ; Focus the first one found and stop
			}
		}
	}
}

SetWorkingDir(A_ScriptDir)
VDA_PATH := A_ScriptDir . "\..\VirtualDesktopAccessor.dll"

hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")
if (!hVirtualDesktopAccessor) {
	MsgBox("Failed to load VirtualDesktopAccessor.dll!`nCheck if the file exists at:`n" . VDA_PATH)
	ExitApp()
}

GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

GetDesktopCount() {
	global GetDesktopCountProc
	count := DllCall(GetDesktopCountProc, "Int")
	return count
}

MoveCurrentWindowToDesktop(number) {
	global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
	activeHwnd := WinGetID("A")
	DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number, "Int")
	DllCall(GoToDesktopNumberProc, "Int", number, "Int")
}

GoToPrevDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, "Int")
	last_desktop := GetDesktopCount() - 1
	; If current desktop is 0, go to last desktop
	if (current = 0) {
		MoveOrGotoDesktopNumber(last_desktop)
	} else {
		MoveOrGotoDesktopNumber(current - 1)
	}
	return
}

GoToNextDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, "Int")
	last_desktop := GetDesktopCount() - 1
	; If current desktop is last, go to first desktop
	if (current = last_desktop) {
		MoveOrGotoDesktopNumber(0)
	} else {
		MoveOrGotoDesktopNumber(current + 1)
	}
	return
}

GoToDesktopNumber(num) {
	global GoToDesktopNumberProc
	DllCall(GoToDesktopNumberProc, "Int", num, "Int")
	return
}

MoveOrGotoDesktopNumber(num) {
	; If user is holding down Mouse left button, move the current window also
	if (GetKeyState("LButton")) {
		MoveCurrentWindowToDesktop(num)
	} else {
		GoToDesktopNumber(num)
	}
	Sleep(250)
	ScanAndFocusFlashing()
	return
}

GetDesktopName(num) {
	global GetDesktopNameProc
	utf8_buffer := Buffer(1024, 0)
	ran := DllCall(GetDesktopNameProc, "Int", num, "Ptr", utf8_buffer, "Ptr", utf8_buffer.Size, "Int")
	name := StrGet(utf8_buffer, 1024, "UTF-8")
	return name
}

SetDesktopName(num, name) {
	global SetDesktopNameProc
	OutputDebug(name)
	name_utf8 := Buffer(1024, 0)
	StrPut(name, name_utf8, "UTF-8")
	ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", name_utf8, "Int")
	return ran
}

CreateDesktop() {
	global CreateDesktopProc
	ran := DllCall(CreateDesktopProc, "Int")
	return ran
}

RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
	global RemoveDesktopProc
	ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
	return ran
}


; Win (Shift) + Tab switches forward (backward) between workspaces
#Tab::GoToNextDesktop()
#+Tab::GoToPrevDesktop()

; hjkl for desktop movement
#j::MoveOrGotoDesktopNumber(0)
#k::MoveOrGotoDesktopNumber(2)
#l::MoveOrGotoDesktopNumber(4)
#h::MoveOrGotoDesktopNumber(6)

; Ctrl + \ selects your current word (or the word in front, if you aren't selecting a word), putting your cursor at the end of it
^\:: {
	Send("^{Right}^{Left}^+{Right}")
}

; Ctrl + Shift + Alt + S makes a window show over all others
^+!S:: { 
	WinSetAlwaysOnTop(-1, "A")

	currentStyle := WinGetExStyle("A")
	if (currentStyle & 0x8) { 
		; 0x8 is WS_EX_TOPMOST. Detects if window is on top
	} else {
		WinMinimize("A")
	}
}

; Ctrl + , sends you to the beginning of a line (Home)
^SC033:: {
	Send("{Home}")
}

; Ctrl + . sends you to the end of a line (End)
^SC034:: {
	Send("{End}")
}

; Ctrl + Shift + , sends you to the beginning of a line, highlighting every character from where your cursor is to there
^+SC033:: {
	Send("+{Home}")
}

; Ctrl + Shift + . sends you to the end of a line, highlighting every character from where your cursor is to there
^+SC034:: {
	Send("+{End}")
}

; Ctrl + Alt + , sends you to the beginning of a file
^!SC033:: {
	Send("^{Home}")
}

; Ctrl + Alt + . sends you to the end of a file
^!SC034:: {
	Send("^{End}")
}

; Ctrl + Shift + Alt + , sends you to the beginning of a file, highlighting all characters from your cursor to there
^+!SC033:: {
	Send("^+{Home}")
}

; Ctrl + Shift + Alt + . sends you to the end of a file, highlighting all characters from your cursor to there
^+!SC034:: {
	Send("^+{End}")
}

; Ctrl + Shift + Backspace deletes your current line and puts you on the one above
^+Backspace:: {
	Send("{End}{Space}+{Home}{Backspace}{Space}+{Home}{Backspace}{Backspace}")
}

; Ctrl + Shift + \ selects your current line, putting your cursor at the beginning of it
^+\:: {
	Send("{Home}{End}+{Home}")
}

; Ctrl + H is Escape
^h:: {
	Send("{Escape}")
}

; Alt + hjkl are like the arrow keys
!h::Send("{Left}")
!j::Send("{Down}")
!k::Send("{Up}")
!l::Send("{Right}")

; Alt + Alt is for Backslash/Pipe
!LAlt::Send("\")
!RAlt::Send("\")
!+LAlt::Send("|")
!+RAlt::Send("|")

; Ctrl + Alt + T opens terminal
^!t::{
	Run('wt')
}

; Holding Shift and clicking M1 while CapsLock is ON toggles an autoclicker 
; Disable by turning CapsLock OFF
while (true) {
	if (GetKeyState("CapsLock", "T")) {
		if (GetKeyState("LShift", "P") && GetKeyState("LButton", "P")) {
			while (GetKeyState("CapsLock", "T")) { 
				Click()
				Sleep(25)
			}
		}

		Sleep(25)
	}
}
