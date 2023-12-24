SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, ./Files/Images/HotKey.ico
if not A_IsAdmin
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
#include DefaultHeader-v3.ahk
#include UWPFunctions.ahk
#NoEnv
Header:
FinishHeader(0)
SetTitleMatchMode, 2
CoordMode, Mouse, Screen ; for Mouse monitor remap
DetectHiddenWindows, on
VarSetCapacity(CursorPos, 4+4, 0)
SetTimer, MousePortal, 50
#WinActivateForce
EnvGet, Malek, Malek
EnvGet, AHK, AHK
if Malek
	MMPath := Malek . "MiscMacro.ahk"
if AHK
	CompileC := AHK . "\XPS Programs\CompileC.ahk"
if FileExist(MMPath) 
	Menu, Tray, Add, Reset MiscMacro, ResetMisc
if FileExist("NoInput.ahk")
	Menu, Tray, Add, Launch NoInput, NoInput
if FileExist(Malek . "\TechKeys.ahk")
	Menu, Tray, Add, Launch TechKeys, TechKeys
FinishHeader(1)


#If
; Remaps - Begin
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
; :*:STRIPPED::REPLACED

<!x:: ; Force Close MiscMacro.ahk(s)
	DetectHiddenWindows, On
	WinGet, numInstances, Count, MiscMacro.ahk - AutoHotkey
	Loop, %numInstances% {
		WinGet, MiscMacroPID, PID, MiscMacro.ahk - AutoHotkey
		RunWait, taskkill.exe /F /PID %MiscMacroPID%,, min
	}
	Tooltip %numInstances% MiscMacro instance(s) closed
	SetTimer, RemoveToolTip, -2000
	MouseGetPos, origX, origY	; Remove dead MiscMacro Tray Icons
	xpos := 1808+28 ; 28 pixels from center to center
	ypos := 825-28
	loopCount := numInstances + 3
	Loop, %loopCount% {
		if (A_Index == loopCount-1) ; Drop down a level for the final 2 icons
			ypos := ypos+28
		MouseMove, %xpos%, %ypos%, 0
		xpos := xpos==1808+28 ? xpos+28+28 : xpos-28-28
	}
	MouseMove, origX, origY, 0
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

^+#e::Reload ; Run, notepad++.exe "%A_ScriptFullPath%" ; Edit MiscRemap
^+!e::Edit ; Run, notepad++.exe "%A_ScriptFullPath%" ; Edit MiscRemap
^+#n::
	Run, notepad++.exe ; Launch Notepad++
	WinWaitActive, ahk_class Notepad++,, 5 ; ahk_exe notepad++.exe,, 5
	if !ErrorLevel
		; Sleep 50 ; 250
		Send !fn ; ^n
	return

^+#s::oneRun("ahk_exe SpotifyLyrics.exe", Malek . "SpotifyLyrics.exe")

>^Esc::Goto, NoInput ; Launch NoInput
^+#y::Goto, YouTubeSpeed ; Launch YouTubeSpeed

:*:mnygp@::mnygp@umsystem.edu ; Autocomplete Mizzou email address
:*:Malek_::Malek_Necibi

^+#c::Run %CompileC% ; Run Compiler Script
^+#!c::Run notepad++.exe "%CompileC%" ; Edit Compiler Script
^#!c::Winkill, ahk_exe ubuntu.exe ; Stop Compiler Script

^+#t::Goto, TechKeys ; Run TechKeys Macro Remap
^+#!t::Run, notepad++.exe %Malek%\TechKeys.ahk ; Edit TechKeys Mappings

+Volume_Up::SoundSet, +1 ; Increment Volume by 1
+Volume_Down::SoundSet, -1 ; Decrement Volume by 1

^!Up::MouseMove, 3737, -1080 ; Center of BenQ
^!Down::MouseMove, 960, 600 ; Center of XPS

^!m::Run bthprops.cpl ; "Quick-Connect" to Bluetooth Device (#k instead)
^+#1::ConnectBT("Malek's Powerbeats Pro")
^+#2::ConnectBT("Malek's QC35")
^+#0::ConnectBT(0)

; ^\::Send {U+00AB} ; «  ; CS 3330 - UML Symbols
; ^+\::Send {U+00BB} ; »

$>!\:: ; calc.exe Shortcuts, only 1 instance
$>^\::
$>^>!\::oneRun("Calculator","calculator://")

$F6::adjustBrightness(-1) ; Fine Brightness Control
$F7::adjustBrightness(1)

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
; Global Remaps - End

; Conditional Remaps - Begin
#If WinActive("ahk_class Shell_TrayWnd")
^+#m::Run, notepad++.exe %Malek%\MiscMacro.ahk ; Edit MiscMacro if Taskbar Selected

#If !WinActive("ahk_class Shell_TrayWnd") ; Launch/Restart MiscMacro
^+#m::Run, %Malek%\MiscMacro.ahk

#If WinActive("ahk_exe explorer.exe")
AppsKey:: ; Extended Context Menu
RButton::SendInput {shift down}{%A_ThisHotkey%}{shift up}
^+#=::SendInput {AppsKey}n{Left}{Enter}{Esc 2} ; Edit with Notepad++
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
;				pathToBash(filePath)	; Removed b/c breaks SplitPath compatibility
;				if (fileExt == "pdf") {	; limit to pdfs (no images)
					inputFile = '%fileName%'	; escape file name
;					outputFile := fileNameNoExt . "_ocr." . fileExt
;					outputFile = '%outputFile%')
					outputFile = '%fileNameNoExt%_ocr.pdf'	; escape file name, set extension
					
					; sudo ocrmypdf --force-ocr --jobs 2 file.pdf file_ocr.pdfs
					; command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && ocrmypdf --force-ocr --jobs 2 %inputFile% %outputFile% `; bash
					command = echo OCR Convert: \'%inputFile%\' && cd %bashDir% && sudo ocsrmypdf --force-ocr --jobs 2 %inputFile% %outputFile% `; bash
					
;					Winkill, ahk_exe ubuntu.exe
					Run, ubuntu run %command%
;				}
			}
		}
	} else {
		MsgBox ERROR: Unable to get File-Path from Clipboard (%ErrorLevel%)
	}
	Clipboard := ClipSave
	ClipSave := ""
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
			ToolTip, %FileName% %State% Read-Only, A_ScreenWidth/2, A_ScreenHeight/2
			SetTimer, RemoveToolTip, -1500
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
	return
^+#u:: ; Unblock Downloaded File
	Send !{Enter}
	WinWaitActive, Properties
	if !ErrorLevel
		Send k{Enter}
	return
~m:: ; Fix Explorer Rename (b/c OneDrive)
	if ( (A_PriorKey == A_PriorHotkey) && ((A_PriorKey == "AppsKey") || (A_PriorKey == "RButton")) )
		Send {Esc}{F2}
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
	; SendInput STRIPPED
	KeyWait, Enter, D T3
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
~Esc::
	saveTextState := A_DetectHiddenText
	DetectHiddenText, off
	WinGetText, chromeText,, Chrome Legacy Window
	if (chromeText != "Chrome Legacy Window`r`n")
		SendInput {Esc}{F12}	; Hide Console then close Inspect Element
	DetectHiddenText, %saveTextState%
	return
$>!PgDn::SendInput ^{PgDn} ; Fix common mistake when changing tab
$>!PgUp::SendInput ^{PgUp}
:*:ahk::{Backspace 3}autohotkey
$^+r::SendInput ^+t
; $>!LButton::SendInput >^{LButton}
$^+PgUp::Send ^l{F6}^{Left}^l+{F6} ; Shift current tab position
$^+PgDn::Send ^l{F6}^{Right}^l+{F6}
^+f::^+a


#If WinActive("ahk_exe ubuntu.exe") ; VIM Remaps
; mnygp@clark-r630-login-node907 ; VIM Remaps
^s::SendInput {Esc 4}:w{Enter}i{Right}
^w::SendInput {Esc 4}:wq{Enter}
; $^Left::SendInput {Esc 4}bi
; $^Right::SendInput {Esc 4}{Right}wi
^Down::SendInput ^t{Down}{Home}
+Down::SendInput {Esc 4}{Home}wi{BackSpace}{Down}{Home}
^z::SendInput {Esc 4}{u}i
^u::SendInput {Esc 4}^{r}i
^f::SendInput {Esc 4}?
^g::SendInput {Esc 4}:nohlsearch{Enter}i{Right}

#If WinActive("ahk_exe winword.exe") or WinActive("ahk_exe powerpnt.exe")
^PgDn::^Right

	return
^.::Send *{Tab}

#If WinActive("ahk_exe notepad++.exe")
^0::SendInput ^{NumpadDiv}
^=::SendInput ^{NumpadAdd}
^-::SendInput ^{NumpadSub}
Insert::End

#If WinActive("ahk_exe thonny.exe")
!s::F5 ; Run program from !s
~^PgDn::^Tab ; Change tab like Chrome Shortcut
~^PgUp::^+Tab

#If WinActive("ahk_exe javaw.exe") && WinExist(" | Arduino ")
!s::^r ; Compile code from !s
^q::return  ; Prevent accidentally closing Arduino
Insert::return	; Often accidentally pressed instead of End
^w::
	ToolTip, You almost closed the Arduino IDE!
	SetTimer, RemoveToolTip, -1500
	return
^0::
	SendInput ^{,}
	WinWaitActive, Preferences
	if !ErrorLevel
		Send {Tab 3}^a12+{Tab 5}{Enter}
	return

#If WinActive("ahk_exe netbeans64.exe")
$!s:: ; Kills existing process before running new instance
	Send ^``
	WinWaitClose, ahk_exe java.exe,,1
	Send !s
	return
$^!s:: ; Kills existing process before running new instance
	Send ^``
	WinWaitClose, ahk_exe java.exe,,1
	Send ^!s
	return
Insert::return
^.::^/

#If WinActive("ahk_exe java.exe") and WinExist("ahk_exe netbeans64.exe")
$Esc::
	WinGet, javaPID, PID, A
	Process, Close, %javaPID%
	return

#If !WinExist("TechKeys.ahk ahk_class AutoHotkey")
^+!F1::
^+!F2::
^+!F3::
^+!F4::
^+!F5::
^+!F6::Goto, TechKeys

#If WinActive("ahk_exe explorer.exe") && WinActive("search-ms:")
Enter::
	ClipSave := ClipboardAll
	Clipboard := ""
	Send ^c
	ClipWait, 1
	if !ErrorLevel {
		FilePath := Clipboard
		Clipboard := ClipSave
		ClipSave := ""
;		if InStr(FileExist(FilePath), "D"){
;			Send {Alt}jso
			Send {AppsKey}
			Sleep 250
			Send i
;		} else
;			Send {Enter}
	} else {
		Send {Enter}
	}
	ErrorLevel := 0
	return

#If WinActive("ahk_exe MobaXterm.exe")
:*:`:W:::w ; Replace accidental :Wqs with :wq
Insert::return

#If WinActive("ahk_class #32770", "Type the name of a program") ; Remap Run commands
:*:calc::calc1

#If WinActive("ahk_exe wookie.exe")
^-::F1 ; Remap Zoom
^=::F2
!s::Send {F11}

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
		Tooltip ConnectBT() Error: Couldn't open CONNECT QuickMenu
		SetTimer, RemoveToolTip, -2500
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

oneRun(title, runPath, matchMode := 3) {
	saveMode := A_TitleMatchMode
	SetTitleMatchMode, %matchMode%
	if WinExist(title)
		WinActivate
	else
		Run, %runPath%
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
; Functions - End

; Labels - Begin
NoInput:
if FileExist("NoInput.ahk")
	Run, NoInput.ahk
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
	Run, YouTubeSpeed.ahk 
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

Nothing:
return

RemoveToolTip:
ToolTip
return
; Labels - End