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

; Ctrl + Alt + T opens terminal
^!t::Run('wt')

; Win (Shift) + Tab switches forward (backward) between workspaces
#Tab::{
	Send("^#{Right}")
}

#+Tab::{
	Send("^#{Left}")
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
