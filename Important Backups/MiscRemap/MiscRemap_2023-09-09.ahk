SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, .\Files\Images\HotKey.ico
if not A_IsAdmin
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
#include Files\lib\DefaultHeader-v3.ahk
#include Files\lib\UWPFunctions.ahk
#include Files\lib\SnapActiveWindow.ahk
#include Files\lib\TrayRefresh.ahk
#include Files\lib\RunAsUser.ahk	; run as non-elevated user
#NoEnv
Header:
FinishHeader(0)
SetTitleMatchMode, 2
CoordMode, Mouse, Screen ; for Mouse monitor remap
DetectHiddenWindows, on
VarSetCapacity(CursorPos, 4+4, 0)
SetTimer, MousePortal, 50
SetTimer, CheckModifiers, 250
SetTimer, ClearFocusAssist, % 4*60*60*1000	; Reset Focus Assist Every 4 hours
#KeyHistory 500
#WinActivateForce
EnvGet, Malek, Malek
EnvGet, AHK, AHK
if Malek
	MMPath := Malek . "MiscMacro.ahk"
if AHK
	CompileC := AHK . "\XPS Programs\CompileC.ahk"
if FileExist(MMPath) 
	Menu, Tray, Add, Reset MiscMacro, ResetMisc
if FileExist("Files\lib\NoInput.ahk")
	Menu, Tray, Add, Launch NoInput, NoInput
if FileExist(Malek . "\TechKeys.ahk")
	Menu, Tray, Add, Launch TechKeys, TechKeys
FinishHeader(1)

; debug := 1	; Forgot what this does, commented out 4/26/22

GroupAdd, linux_shell, "ahk_exe ubuntu.exe"
GroupAdd, linux_shell, "ahk_exe mintty.exe"
GroupAdd, linux_shell, "ahk_exe MobaXterm.exe"
GroupAdd, linux_shell, "ahk_exe wsl.exe"

#If
; Remaps - Begin

; Hotstrings - Begin
:*:mnygp@::mnygp@umsystem.edu ; Autocomplete address
:*:m.n@::Malek.Necibi@veteransunited.com
:*:Malek_::Malek_Necibi
; :*:e8e::STRIPPED
; HotStrings - End

; Hotkey Command Remaps - Begin
Hotkey, IfWinActive, ahk_class Chrome_WidgetWin_1 ; Fix Tab Number Selection with Chrome Tab Groups
Loop 8 {
	Hotkey, ^%A_Index%, ChromeGroupsTabCount
}

Hotkey, IfWinActive, ahk_exe explorer.exe ; Send as Numpad
SetNumLockState, On
Loop 10 {
	num := A_Index-1
	Hotkey, *%num%, Numpad
	Hotkey, *%num% up, Numpad
	Hotkey, +%num%, Numpad
}
; Hotkey Command Remaps - End

; Global Remaps - Begin
<!x::
	DetectHiddenWindows, On
	WinGet, MiscMacroIDs, List, MiscMacro.ahk - AutoHotkey
	; WinGet, numInstances, Count, MiscMacro.ahk - AutoHotkey
	numInstances := MiscMacroIDs	; w/o trailing integer == size of the pseudo-array
	Loop, %numInstances% {
		; NOTE: Next line is weird and easy to misunderstand
		; Dynamic Variable Naming
		; (1) set the VALUE of currentID to the NAME of another variable
			; MiscMacroIDs := 0x123456
			; currentID := "MiscMacroIDs4"
		; (2) set the VALUE of currentID to the VALUE of the variable name currentID is possesses
			; currentID := MiscMacroIDs4
			; currentID now equals 0x123456
		; currentID = % MiscMacroIDs%A_Index%
		; currentID := MiscMacroIDs%A_Index%	; Equivalent to line above
		; WinGet, MiscMacroPID, PID, ahk_id %currentID%
		
		; See above comment. Additionally merged the variable declaration and command call
		WinGet, MiscMacroPID, PID, % "ahk_id " . MiscMacroIDs%A_Index%
		Run, taskkill.exe /F /PID %MiscMacroPID%,, min
	}
	Tooltip(-1, "Closing all MiscMacro instances...")
	;Tooltip, Closing all MiscMacro instances...
	WinWaitClose, MiscMacro.ahk - AutoHotkey,,10
	if ErrorLevel {
		Tooltip(,"ERROR: Failed to close MiscMacro")
		;Tooltip, ERROR: Failed to close MiscMacro
		;SetTimer, RemoveToolTip, -1500
		return
	}
	Tooltip(2000, numInstances " MiscMacro instance(s) closed")
	Tray_Refresh()	; Automated Dead Tray Icon remover
	/* ; Manually moving mouse
	;SetTimer, RemoveToolTip, -2000
	; Remove dead MiscMacro Tray Icons
	MouseGetPos, origX, origY	; Save cursor position
	WinGetPos, TrayX, TrayY, TrayWidth, TrayHeight, ahk_class Shell_TrayWnd
	if (TrayHeight > TrayWidth) {	; Vertical Taskbar
		iconSize := TrayWidth * 1/3	  ; 37.3
		; 'Initial position' tray icon(s) to remove
		iconX0 := 1845	  ; TrayX + TrayWidth * 1/3
		iconY0 := 924	  ; TrayY + TrayHeight * 77/100
		iconClearLoopCount := 1+Floor(numInstances / 20)
		; (numInstances < 15) ? 1 : 1+Ceil(numInstances/50)	 ; Prevent running unnecessarily long
		Loop % iconClearLoopCount {
			MouseMove, %IconX0%, %IconY0%, 0	; Set cursor to 'home'
			directions := ["R", "U", "L", "U", "R", "U", "L", "U", "R", "D", "D", "D", "D", "L"]
			Loop % directions.Length() {
				deltaX := 0
				deltaY := 0
				switch directions.RemoveAt(1) {
					Case "U":
						deltaY := -iconSize	  ; Up
					Case "D":
						deltaY := iconSize	  ; Down
					Case "L":
						deltaX := -iconSize	  ; Left
					Case "R":
						deltaX := iconSize	  ; Right
				}
				MouseMove, %deltaX%, %deltaY%, 1, R
			}
		}
	}
	MouseMove, origX, origY, 0
	*/
	return
	
^+#!x::	; Force Pause+Suspend All AHK Scripts
	DetectHiddenWindows On
	WinGet, ID, List, ahk_class AutoHotkey
	Loop, %id%
	{
		this_id := id%A_Index%
		PostMessage, 0x111, 65305,,, ahk_id %this_id%
		PostMessage, 0x111, 65306,,, ahk_id %this_id%
	}
	return

^+#e::Reload
^+!e::RunAsUser("C:\Program Files\Notepad++\notepad++.exe", """" . A_ScriptFullPath . """") ; Edit ; Run, notepad++.exe "%A_ScriptFullPath%"
^+!n::RunAsUser("C:\Program Files\Notepad++\notepad++.exe") ; Launch Notepad++
^+#n::
	; Run, notepad++.exe ; Launch and Create New Notepad++ Page
	RunAsUser("C:\Program Files\Notepad++\notepad++.exe")
	WinWaitActive, ahk_class Notepad++,, 5 ; ahk_exe notepad++.exe,, 5
	if !ErrorLevel
		; Sleep 50 ; 250
		Send !fn ; ^n
	return

^+#s::oneRun("ahk_exe SpotifyLyrics.exe", Malek . "SpotifyLyrics.exe")

>^Esc::Goto, NoInput ; Launch NoInput
^+#y::Goto, YouTubeSpeed ; Launch YouTubeSpeed



; ^+#c::Run %CompileC% ; Run Compiler Script
; ^+#!c::return ; Run notepad++.exe "%CompileC%" ; Edit Compiler Script
; ^#!c::Winkill, ahk_exe ubuntu.exe ; Stop Compiler Script

; ^+#t::Goto, TechKeys ; Run TechKeys Macro Remap
; ^+#!t::return ; Run, notepad++.exe %Malek%\TechKeys.ahk ; Edit TechKeys Mappings

; +Volume_Up::SoundSet, +1 ; Increment Volume by 1
; +Volume_Down::SoundSet, -1 ; Decrement Volume by 1

; ^!Up::MouseMove, 3737, -1080 ; Center of BenQ
; ^!Down::MouseMove, 960, 600 ; Center of XPS

; ^!m::Run bthprops.cpl ; "Quick-Connect" to Bluetooth Device (#k instead)
^!m::RunAsUser("rundll32.exe", "shell32.dll,Control_RunDLL bthprops.cpl") ; Run bthprops.cpl 
^+#1::ConnectBT("Powerbeats Pro")
^+#2::ConnectBT("Malek's QC35")
^+#3::ConnectBT("Tribit Stormbox")
^+#4::ConnectBT("TOZO-T10")
^+#0::ConnectBT(0)

; ^\::Send {U+00AB} ; «  ; CS 3330 - UML Symbols
; ^+\::Send {U+00BB} ; »

$>!\:: ; calc.exe Shortcuts, only 1 instance
$>^\::
$>^>!\::oneRun("Calculator","calc.exe",, "Calculator")
; $>^>!\::oneRun("Calculator","calculator://",, "Calculator")

; $F6::adjustBrightness(-1) ; Fine Brightness Control
; $F7::adjustBrightness(1)

$^F6::setBrightness(0) ; Absolute Brightness Control
$^F7::setBrightness(100)

^+v:: ; Paste Text Only w/o changing
	ClipSave := ClipboardAll
	ClipText := Clipboard
	Clipboard := ""
	Clipboard := ClipText
	ClipWait, 1
	Send ^v
	Sleep 250 ; Asynchronous pasting can take long time. Failed to find better alternative
	Clipboard := ClipSave
	ClipSave := ""
	ClipText := ""
	return

^+#m::RunAsUser(A_AhkPath, MMPath)
^+!m::RunAsUser("C:\Program Files\Notepad++\notepad++.exe", MMPath)
;^+!m:: Run, notepad++.exe %Malek%\MiscMacro.ahk ; Edit MiscMacro if Taskbar Selected

; ~#x:: ; Close WinX Menu when opening Run dialog
	; Hotkey, #r, WinXRun, On
	; KeyWait, r, D T5
	; Hotkey, #r, WinXRun, Off
; return

; Replaced by modifying WinX Menu (see Group3 email)
; ~#x:: ; Replace Powershell with TerminalPreview in WinX Menu
; 	Hotkey, i, RunTerminal, On
; 	KeyWait, i, D T3
; 	; Wait max 3 seconds for 'i' key override
; 	Hotkey, i, RunTerminal, Off
; return

$Insert::return	; Ignore accidental Insert

; Custom Window Snap (top-half, bottom-half, re-center)
#!Up::WindowSnap(2, 1, 1, 1)
#!Down::WindowSnap(2, 1, 2, 1)
; #Up::WinMaximize, A
; #Up::Send #{Right} ; FancyZones
; #Down::WindowSnap(8, 6, 2, 2, 6, 4)
; #Down::WindowSnap(10, 6, 3, 2, 6, 4)

; Snipping Tool Quick-Launch
^+!s::
	; Run, snippingtool.exe
	RunAsUser("SnippingTool.exe")
	WinWaitActive, ahk_exe SnippingTool.exe
	; Send ^s	; Enable to avoid losing previous (unsaved) snip
	Send ^n
	return

$#r::Send !{space}
!r::Send #r
#t::GoSub, RunTerminal
#If

; Disable built-in Office Shortcut
#^!Shift::
#^+Alt::
#!+Ctrl::
^!+LWin::
^!+RWin:: 
Send {Blind}{vkFF}
return

; Global Remaps - End

; Conditional Remaps - Begin
#If WinActive("ahk_exe explorer.exe")
AppsKey:: ; Extended Context Menu
RButton::
	SendInput {shift down}{%A_ThisHotkey%}{shift up}
	;Tooltip(, "context")
	return
^+#=::
	SendInput {AppsKey}n{Left}{Enter}{Esc 2} ; Edit with Notepad++
	;Tooltip(5000, "equal")
	return
^+#p:: ; Convert Selected File to Searchable PDF (ocr)
	ClipSave := ClipboardAll
	Clipboard := ""
	SendInput ^c
	Clipwait, 0
	if !ErrorLevel {
		filePath := Clipboard
		if ("" = FileExist(filePath)) {
			MsgBox File Not Found:`n%filePath%
			
		} else {
			; Convert file paths to bash
			; ex. "C:\Users\Folder Name" -> '/mnt/c/Users/Folder Name'
			SplitPath, % filePath  , fileName, fileDir, fileExt, fileNameNoExt, fileDrive
			StringLower, bashDrive, fileDrive
			bashDrive := RegExReplace(bashDrive, ":", "")	; C:\ -> /mnt/c
			if ( 1 == StrLen(bashDrive)) {	; Limit to mounted drives
				bashDir := StrReplace(SubStr(fileDir, InStr(fileDir,":") + 1),"\","/")
				bashDir = '/mnt/%bashDrive%%bashDir%'	; merge and escape
				; pathToBash(filePath)	; Removed b/c breaks SplitPath compatibility
				; if (fileExt == "pdf") {	; limit to pdfs (no images)
					inputFile = '%fileName%'	; escape file name
 					; outputFile := fileNameNoExt . "_ocr." . fileExt
 					; outputFile = '%outputFile%')
					outputFile = '%fileNameNoExt%_ocr.pdf'	; escape file name, set extension
					outputTextFile = '%fileNameNoExt%_ocr.txt'	; escape file name, set extension
					
					; Experimental: --redo-ocr (looks promising)
					command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && sudo ocrmypdf --redo-ocr --jobs 2 %inputFile% %outputFile% `; bash
					
					; Default, drop all text and ocr the whole document
					; command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && sudo ocrmypdf --force-ocr --jobs 2 %inputFile% %outputFile% `; bash
					
					; Default + export text to txt file
					; command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && sudo ocrmypdf --force-ocr --jobs 2 --sidecar %outputTextFile% %inputFile% %outputFile% `; bash
					
					; Default + auto-rotate + export text to txt file
					; command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && sudo ocrmypdf --force-ocr --jobs 2 --rotate-pages --sidecar %outputTextFile% %inputFile% %outputFile% `; bash
					
					; Winkill, ahk_exe ubuntu.exe
					Run, ubuntu run %command%
;				}
			}
		}
	} else {
		MsgBox ERROR: Unable to get File-Path from Clipboard (%ErrorLevel%)
	}
	Clipboard := ClipSave
	ClipSave := ""
	;Tooltip(5000, "searchable pdf")
	return
^+#r:: ; Make selected file read-only
	ClipSave := ClipboardAll
	Clipboard := ""
	SendInput ^c
	Clipwait, 1
	if !ErrorLevel {
		FilePath := Clipboard
		SplitPath, % FilePath , FileName
		FileSetAttrib, ^R, %FilePath%
		FileGetAttrib, Attribs, %FilePath%
		if (!A_LastError) {
			State := InStr(Attribs, "R") ? "is now" : "no longer"
			Tooltip(, FileName " " State " Read-Only", A_ScreenWidth/2, A_ScreenHeight/2)
			;ToolTip, %FileName% %State% Read-Only, A_ScreenWidth/2, A_ScreenHeight/2
			;SetTimer, RemoveToolTip, -1500
		} else {
			if (A_LastError == 2) {
				MsgBox ERROR: File '%FileName%' Not Found 
			} else {
				MsgBox ERROR: File Attribute wasn't Changed (%A_LastError%)
			}
		}
	} else {
		MsgBox ERROR: Unable to get File-Path from Clipboard (%ErrorLevel%)
		ErrorLevel := 0
	}
	Clipboard := ClipSave
	ClipSave := ""
	FilePath := ""
	;Tooltip(5000, "read-only")
	return
^+#u:: ; Unblock Downloaded File
	Send !{Enter}
	WinWaitActive, Properties
	if !ErrorLevel
		Send k{Enter}
	;Tooltip(5000, "unblock")
	return
~m:: ; Fix Explorer Rename (b/c OneDrive)
	if ( (A_PriorKey == A_PriorHotkey) && ((A_PriorKey == "AppsKey") || (A_PriorKey == "RButton")) )
		Send {Esc}{F2}
	;Tooltip(5000, "rename")
	return

#If WinActive("ahk_class Chrome_WidgetWin_1") ; Google Chrome
>^>!VK4C::
^+#VK4C::
	WinGetTitle, initialTitle, A
	preopened := RegExMatch(initialTitle, "^$") ; Check if dialog already open
	if (0 != verifyIdentity())
		return
	saveMode := A_TitleMatchMode ; Backup b/c switch to Regex
	SetTitleMatchMode RegEx
	if (preopened)
		Send {Tab}	; b/c Verify loses input box focus
	else
		SendInput ^+x
	WinWaitActive, ^$,, 1	; ^$ = Empty String
	if ErrorLevel
		Goto, SafeQuit1P
	Sleep 250
	; SendInput STRIPPED
	KeyWait, Enter, D T3 ; Wait up to 3 seconds
	Send {F6}+{F6}	; Revert to initial view
	if ErrorLevel	; from KeyWait
		Goto, SafeQuit1P
	SetTitleMatchMode, 3
	WinWaitActive, %initialTitle%,, 1
	if !ErrorLevel {
		Sleep 250
		Send {Down}	; Pre-Select top field
	}
	SafeQuit1P:	; Label for quitting gracefully
	SetTitleMatchMode, %saveMode%
	return
Esc::	; Hide Console then close Inspect Element
; $Esc::
	saveTextState := A_DetectHiddenText
	DetectHiddenText, off
	WinGetText, chromeText,, Chrome Legacy Window
	if (chromeText == "Chrome Legacy Window`r`nChrome Legacy Window`r`n") {
		SendInput {F12}	; Hide Console then close Inspect Element
	} else {
		SendInput {Esc}
	}
	DetectHiddenText, %saveTextState%
	return
:*:ahk::{Backspace 3}autohotkey
$^PgUp::^+Tab ; Fix tab switch in pdf's
$^PgDn::^Tab
$>!PgDn::SendInput ^{Tab} ; ^{PgDn} ; Fix common mistake when changing tab
$>!PgUp::SendInput ^+{Tab} ; ^(PgUp}
$^+PgUp::Send ^l{F6}^{Left}^l+{F6} ; Shift current tab position
$^+PgDn::Send ^l{F6}^{Right}^l+{F6}
; $>!LButton::SendInput >^{LButton}
$^+r::SendInput ^+t
; ^+f::^+a ; search all tab names
; <^f::^+f ; Regex Find+ Search
; ^Enter::SendInput +{Enter}  ; ChatGPT New Line

; #If WinActive("ahk_exe ubuntu.exe") ; VIM Remaps
; ; mnygp@clark-r630-login-node907 ; VIM Remaps
; ^s::SendInput {Esc 4}:w{Enter}i{Right}
; ^w::SendInput {Esc 4}:wq{Enter}
; ; $^Left::SendInput {Esc 4}bi
; ; $^Right::SendInput {Esc 4}{Right}wi
; ^Down::SendInput ^t{Down}{Home}
; +Down::SendInput {Esc 4}{Home}wi{BackSpace}{Down}{Home}
; ^z::SendInput {Esc 4}{u}i
; ^u::SendInput {Esc 4}^{r}i
; ^f::SendInput {Esc 4}?
; ^g::SendInput {Esc 4}:nohlsearch{Enter}i{Right}

#If WinActive("ahk_exe winword.exe") or WinActive("ahk_exe powerpnt.exe")
^PgDn::^Right
^PgUp::^Left
<^Backspace::
	BatchSave := A_BatchLines, KeySave := A_KeyDelay, ClipSave := ClipboardAll
	SetBatchLines, -1
	SetKeyDelay, -1
	Clipboard := ""
	SendInput +{Right}^c+{Left}^{Backspace}
	ClipWait, 3
	Send {LShift}{RShift}{LCtrl}{RCtrl}
	if ((StrLen(Clipboard) == 1) && ((Clipboard == A_Space) OR (RegExMatch(Clipboard,"[[:punct:]]") != 0))) {
		SendInput {Space}
	}
	Clipboard := ClipSave
	SetKeyDelay, %KeySave%
	SetBatchLines, %BatchSave%
	BatchSave:="", KeySave:="", ClipSave:=""
	Send {LShift}{RShift}{LCtrl}{RCtrl}
	Send {LShift}
	Send {RShift}
	Send {LCtrl}
	Send {RCtrl}
	Send {LShift}{RShift}{LCtrl}{RCtrl}
	return
^.::Send *{Tab}
<^f::Send {Esc}^f

#If WinActive("ahk_exe notepad++.exe")
^0::SendInput ^{NumpadDiv}
^=::SendInput ^{NumpadAdd}
^-::SendInput ^{NumpadSub}
^/::^q
Insert::End

#If WinActive("ahk_exe javaw.exe") && WinExist(" | Arduino ")
!s::^r ; Compile code from !s
^q::return  ; Prevent accidentally closing Arduino
Insert::return	; Often accidentally pressed instead of End
^w::
	Tooltip(, "You almost closed the Arduino IDE!")
	;ToolTip, You almost closed the Arduino IDE!
	;SetTimer, RemoveToolTip, -1500
	return
^0::
	SendInput ^{,}
	WinWaitActive, Preferences
	if !ErrorLevel
		Send {Tab 3}^a12+{Tab 5}{Enter}
	return

#If !WinExist("TechKeys.ahk ahk_class AutoHotkey")
^+!F1::
^+!F2::
^+!F3::
^+!F4::
^+!F5::
^+!F6::Goto, TechKeys

#If WinActive("ahk_exe explorer.exe") && WinActive("search-ms:")
; Enter::Send {Alt}jso
NumpadEnter::
Enter::
	ClipSave := ClipboardAll
	Clipboard := ""
	Send ^c
	ClipWait, 0
	if !ErrorLevel and FileExist(Clipboard) {	; Open file location instead of launching file
		Send {Alt}jso
	} else {
		Send {Enter}
	}
	Clipboard := ClipSave
	ClipSave := ""
	return

; #If WinActive("ahk_exe MobaXterm.exe") OR WinActive("ahk_exe ubuntu.exe")
#If WinActive("ahk_group linux_shell")
; :*:`:W:::w ; Replace accidental :Wq with :wq
^v::Send {Esc 5}i{Right}%Clipboard%
; ^s::Send {Esc 5}:w{Enter}i{Right}
; ^w::Send {Esc 5}:wq{Enter}
Insert::return

#If WinActive("ahk_exe PowerLauncher.exe") or WinActive("ahk_class #32770", "Type the name of a program") ; Remap Run commands
:*:calc::calc1
; PowerLauncher
; ahk_class HwndWrapper[PowerLauncher;;9e9374a7-1a63-497e-81c3-c862c43ffa5f]
; ahk_exe PowerLauncher.exe
; ahk_pid 7408

; #If WinActive("ahk_exe wookie.exe")
; ^-::F1 ; Remap Zoom
; ^=::F2
; !s::Send {F11}

; Fix Launching PowerToys Run from Search Bar
#If WinActive("ahk_exe SearchApp.exe")
$#r::Send {Esc}!{Space}

; Click to Play/Pause in VLC
#If WinExist("ahk_exe vlc.exe")
~LButton::
	MouseGetPos ,,,, This_ClassNN
	if(InStr(This_ClassNN, "VLC video output ")) {
		Send {Media_Play_Pause}
		; Sleep 100
		; Send {Space}
	}
	return

; Git Bash remaps
; Hacky fix for bash reverse-i-search slowness when TAB key is used
#If WinActive("ahk_group linux_shell")
; #if WinActive("ahk_exe mintty.exe") or WinActive("ahk_exe ubuntu.exe") or WinActive("ahk_exe wsl.exe")
~^r::return		; triggers reverse-i-search
~Left::		; keys that quit reverse-i-search
~Right::	; tilde so we dont suppress the key for normal use
~Enter::
~Home::
~End::
~Esc::
~^c::return
$Tab::
	; If we're still in reverse-i-search
	if (A_PriorHotkey == "~^r") {
		Tooltip(, "Warning: Tab crisis averted")
		Send {right}
	} else {
		Send {Tab}
	}
	return

; Youtube Fine Rewind/Fast-Forward
#If WinActive("ahk_class Chrome_WidgetWin_1") && WinActive("YouTube - Google Chrome")
+j::      ; -2.5
+l::      ; +2.5
+Left::	  ; -1.25
+Right::  ; +1.25
	ThisKey := SubStr(A_ThisHotkey, 2) ; Strip leading modifier (+) from keyname
	SendInput +{, 3}{%ThisKey%}+{. 3}
	return



#If
; Conditional Remaps - End
; Remaps - End


; Functions - Begin
ConnectBT(DeviceName := "") { ; Input 0 to fix issues with Connect Menu
	if (0 != DeviceName && WinActive("CONNECT") && WinActive("ahk_class Windows.UI.Core.CoreWindow")) {
		; If Connect Menu already open, safely close it
		ConnectBT(0)
		Sleep 500
	}
	
	Send #k ; Open Quick Connect Menu
	WinWaitActive, CONNECT,, 1
	if ErrorLevel {
		ToolTip(1500, "ConnectBT() Error: Couldn't open CONNECT QuickMenu")
		;Tooltip ConnectBT() Error: Couldn't open CONNECT QuickMenu
		;SetTimer, RemoveToolTip, -2500
		; Optional, open Bluetooth Settings menu if Connect QuickMenu doesn't open
		; if (0 != DeviceName)
			; Run bthprops.cpl
		return
	}
	
	; Fixes Connect QuickMenu issues
	if (0 == DeviceName) {
		SendInput -{Tab}-{Tab}-{Tab}-{Tab}-{Tab}-{Esc}
	
	; Search and Select the given device
	} else {
		Sleep 500
		if WinActive("CONNECT")
			Send {Enter}
		Sleep 750
		if WinActive("CONNECT")
			SendInput %DeviceName%
		Sleep 500
		if WinActive("CONNECT")
			SendInput +{Tab 3}{Down}{Up}{Enter}
	}
	return
}

oneRun(title, runPath, matchMode:=3, text:="") {
	saveMode := A_TitleMatchMode
	SetTitleMatchMode, %matchMode%
	if WinExist(title, text)
		WinActivate
	else
		RunAsUser("""" . runPath . """")
		; Run, %runPath%
	SetTitleMatchMode, %saveMode%
	return
}

setBrightness(level := 50) { ; range = 5-100
	minBrightness := 5  ; levels below this are equivalent
	maxBrightness := 100
	
	if (level < minBrightness)
		level := minBrightness
		
	else if (level > maxBrightness)
		level := maxBrightness
	
	service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
	monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")
	
	for i in monMethods {
		i.WmiSetBrightness(1, level)
	}
}

getBrightness() {
    service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
	monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE")
	
	; if monitors[proc]
	
	for i in monitors { ; only reading from 1st monitor, but for-loop still needed
		return i.CurrentBrightness
	}
}

adjustBrightness(delta) { ; returns new brightness
	current := getBrightness()
	newVal := current + delta
	setBrightness(newVal)
	realVal := getBrightness()
	if (realVal != newVal) {
		dir := (delta>0) - (delta<0)
		if ((realVal < newVal) && (dir == 1))
			setBrightness(newVal+1)
			
		else if ((realVal > newVal) && (dir == -1))
			setBrightness(newVal-1)
	}
	return getBrightness()
}

; returns 0: success, otherwise: failure
verifyIdentity() {
	
	static IUserConsentVerifierStatics, UserConsentVerifierAvailability
	
	if (UserConsentVerifierAvailability = "") {	; Only Instantiate Class Once
		CreateClass("Windows.Security.Credentials.UI.UserConsentVerifier", IUserConsentVerifier := "{AF4F3F91-564C-4DDC-B8B5-973447627C65}", IUserConsentVerifierStatics)
		DllCall(NumGet(NumGet(IUserConsentVerifierStatics+0)+6*A_PtrSize), "ptr", IUserConsentVerifierStatics, "ptr*", UserConsentVerifierAvailability)   ; CheckAvailabilityAsync()
		WaitForAsync(UserConsentVerifierAvailability)
	}
	
	if (UserConsentVerifierAvailability == 0) {	; Obtaining User Consent is Possible
		CreateHString("For security, please verify your identity to continue.", verificationHString)
		DllCall(NumGet(NumGet(IUserConsentVerifierStatics+0)+7*A_PtrSize), "ptr", IUserConsentVerifierStatics, "ptr", verificationHString, "ptr*", UserConsentVerificationResult)   ; RequestVerificationAsync(string)
		WaitForAsync(UserConsentVerificationResult)
		DeleteHString(verificationHString)
	
	} else 
		return UserConsentVerifierAvailability
		
	return UserConsentVerificationResult
}


; Convert to bash (ex: "C:\Users\Folder Name" -> '/mnt/c/Users/Folder Name')
pathToBash(filePath) {
	bashPath := ""
;	if ("" = FileExist(filePath)) {
;		MsgBox File Not Found:`n%filePath%
;		
;	} else {
		SplitPath, % filePath,,,,, fileDrive
		if ("" != fileDrive) {	; limit to mounted drives only 
			StringLower, bashDrive, fileDrive
			bashDrive := RegExReplace(bashDrive, ":", "")	; C:\ -> /mnt/c
			if ( 1 == StrLen(bashDrive)) {	; Limit to local files only
				bashPath := StrReplace(SubStr(filePath, InStr(filePath,":") + 1),"\","/")	; remove drive, flip slashes
				; bashPath = '/mnt/%bashDrive%%bashPath%'	; merge and escape
				bashPath = /mnt/%bashDrive%%bashPath%	; merge
			}
		}
;	}
	return bashPath
}


; time: milliseconds to display tooltip, -1 for infinite.
Tooltip(time:=1500, message:="", X:="", Y:="", WhichToolTip:="")
{
	if time is not number	; If Var is Type doesn't allow inline bracing
	{
		; Throw error, but still show Tooltip message (Recursive Call)
		Tooltip(,"Tooltip() ERROR: Invalid Time Provided (" time ")`n" . message, X, Y, WhichToolTip)
	
	} else {
		Tooltip, %message%, %X%, %Y%, %WhichToolTip%
		if (time >= 0) {	; Persist if time is negative
			SetTimer, RemoveToolTip(), % -1 * time
		}
	}
}

WindowSnap(numRows, numCols, row, col, rowSpan = 1, colSpan = 1) {
	WinRestore, A
	SnapActiveWindowGridSpan(numRows, numCols, row, col, rowSpan, colSpan)
	return
}

ClipSave(ByRef bkp, Timeout := 0, WaitForAnyData := 0) {
	if (bkp = "") {
		bkp := ClipboardAll
		Clipboard := ""
		Send ^c
		ClipWait, Timeout, WaitForAnyData
		
	} else {
		Clipboard := bkp
		bkp := ""
	}
	return !ErrorLevel
}
; Functions - End

; Labels - Begin
NoInput:
if FileExist("Files\lib\NoInput.ahk")
	Run, "Files\lib\NoInput.ahk"	; RunAsUser exception
return

TechKeys:
if FileExist(Malek . "\TechKeys.ahk") {
	Run, %Malek%\TechKeys.ahk
	Sleep 100
	if WinExist("TechKeys.ahk") {
		ToolTip, TechKeys is now running
		SetTimer, RemoveToolTip, -1500
	}
}
return

YouTubeSpeed:
if FileExist("YouTubeSpeed.ahk")
	RunAsUser(A_AhkPath, """" . AHK . "\XPS Programs\YouTubeSpeed.ahk" . """")
return

ResetMisc:
if FileExist(MMPath)
	MsgBox, 4, Reset MiscMacro.ahk, Are you sure you'd like to reset:`r`n%MMPath%
	IfMsgBox, Yes
		{
		FormatTime, FileDateTime,, MM-dd-yyyy-hhmmtt
		MMBPath := Malek . "MiscMacro Backups\MiscMacro." . FileDateTime . ".bkp.ahk"
		FileCopy, %MMPath%, %MMBPath%
		FileRecycle, %MMPath%
		FormatTime, HeaderDateTime,, MM/dd/yyyy hh:mm tt
		FileAppend, `; Created - %HeaderDateTime%`r`n#include DefaultHeader-v3.ahk`r`nHeader:`r`nFinishHeader(`0)`r`nFinishHeader(`1)`r`n`r`n`r`n`r`n`r`n`#If`r`n`; ``::ExitApp`r`n`r`nRemoveToolTip:`r`nTooltip`r`nreturn, %MMPath%
		if (!ErrorLevel)
			MsgBox Reset Successful!`n`nBackup Created at:`n%MMBPath%
		}
	; Run, %Malek%\MiscMacro.ahk
return


MousePortal:	; Teleport mouse cursor between monitors in the corner
SysGet, numDisplays, 80 ; SM_CMONITORS ; Get number of displays
if (numDisplays = 1)
	return
Loop, % numDisplays	; Get pixel bounds for each displays
	SysGet, display%A_Index%, Monitor, %A_Index%
; 'Convert' to portal pixels
xDisplay1 := display1Right-1, yDisplay1 := display1Top ; (Primary Display)
xDisplay2 := display2Left, yDisplay2 := display2Bottom-1 ; (Secondary Display)
; Old Method, Hardcoded Values
; xDisplay1 := 1919, yDisplay1 := 0 ; (XPS Display)
; xDisplay2 := 1818, yDisplay2 := -541 ; (BenQ 4K Monitor)
; xDisplay2 := 1874, yDisplay2 := -1080 ; (Misc)
DllCall("user32.dll\GetCursorPos", Int, &CursorPos)	; Get current cursor position
x := NumGet(CursorPos, 0, "Int")
y := NumGet(CursorPos, 4, "Int")
if (x = xDisplay1 and y = yDisplay1){	; If at portal 1
	DllCall("SetCursorPos", "int", xDisplay2, "int", yDisplay2)	; Teleport to portal 2
} else if (x = xDisplay2 and y = yDisplay2) { ; If at portal 2
	DllCall("SetCursorPos", "int", xDisplay1, "int", yDisplay1)	; Teleport to portal 1
}
return


ChromeGroupsTabCount:
tabNum := SubStr(A_ThisHotkey,2)
Send ^9^{PgDn %tabNum%}
return

Numpad:
num := SubStr(A_ThisHotkey,2,1)
if (SubStr(A_ThisHotkey,1,1) == "+") ; Exception for symbols
	Send +{%num%}
else { ; if ... (Space for future Exceptions)
	dir := (SubStr(A_ThisHotkey, -1) = "up") ? "up" : "DownR"
	Send {Blind}{Numpad%num% %dir%}
	dir := ""
}
num := ""
return

CheckModifiers:
; https://www.autohotkey.com/docs/KeyList.htm#modifier
; modifiers := ["Shift", "RShift", "LShift", "Ctrl", "RCtrl", "LCtrl", "Win", "LWin", "RWin", "Alt", "RAlt", "LAlt"]
modifiers := ["RShift", "LShift", "RCtrl", "LCtrl", "RWin", "LWin", "RAlt", "LAlt"]
ToolTipChanged := false
Loop {
	Sleep 5
	stuckKeys := ""
	for i, key in modifiers {
		key_L := GetKeyState(key)		; Logical state
		key_P := GetKeyState(key, "P")	; Physical state
		if (key_L != key_P) {
			SetTimer,, Off	; Restart testing immediately 
			stuckKeys := stuckKeys . key . "`n"
		}
	}
	if ("" != stuckKeys) {
		Tooltip(, stuckKeys)	; Look into creating multiple tooltips with id's
		ToolTipChanged := true
	}
} Until ("" = stuckKeys)
if (ToolTipChanged) {
	Tooltip(0, "")
}
SetTimer,, On	; Resume slower periodic  testing
return

; Reset Focus Assist to show all notifications
ClearFocusAssist:
Send #b{left}{appskey}fo
Sleep 50
Send !{Esc}
Tooltip(2500, "Focus Assistant: Cleared")
return

MiscKiller:
return

; WinXRun:
; if (A_ThisHotkey = "#r")
	; Send {left}#xr
; if (A_ThisHotkey = "r")
	; tooltip r
; return

RunTerminal:
Send #x{left}{Esc}
; Run, explorer.exe "shell:AppsFolder\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe!App"
; Run wt.exe
RunAsUser("C:\Users\Malek\AppData\Local\Microsoft\WindowsApps\wt.exe") ; Launch Notepad++
return


Nothing:
return

RemoveToolTip:
ToolTip
return

RemoveToolTip():
ToolTip
return
; Labels - End