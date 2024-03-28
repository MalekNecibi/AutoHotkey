Menu, Tray, Icon, %A_ScriptDir%\Files\Images\HotKey.ico
if not A_IsAdmin
    Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.1.ahk
#include %A_ScriptDir%\Files\lib\UWPFunctions.ahk
#include %A_ScriptDir%\Files\lib\SnapActiveWindow.ahk
#include %A_ScriptDir%\Files\lib\TrayRefresh.ahk
#include %A_ScriptDir%\Files\lib\RunAsUser.ahk  ; run as non-elevated user
#include %A_ScriptDir%\Files\lib\Brightness.ahk
#NoEnv
Header:
FinishHeader(0)
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
CoordMode, Mouse, Screen ; for Mouse monitor remap
DetectHiddenWindows, on
VarSetCapacity(CursorPos, 4+4, 0)
SetTimer, MousePortal, 50
SetTimer, CheckModifiers, 250
SetTimer, ClearFocusAssist, % 4*60*60*1000  ; Reset Focus Assist Every 4 hours
#KeyHistory 500
#WinActivateForce
EnvGet, Malek, Malek
EnvGet, AHK, AHK
if Malek
    MMPath := Malek . "MiscMacro.ahk"
if FileExist(MMPath) 
    Menu, Tray, Add, Reset &MiscMacro, ResetMisc
if FileExist("Files\lib\NoInput.ahk")
    Menu, Tray, Add, Launch &NoInput, NoInput
if FileExist(Malek . "\TechKeys.ahk")
    Menu, Tray, Add, Launch &TechKeys, TechKeys
if FileExist(A_WorkingDir . "\Files\lib\FixCursor.ps1")
    Menu, Tray, Add, Fix Hidden &Mouse, FixCursor
FinishHeader(1)

#If
; Remaps - Begin

; Hotstrings - Begin
; :*:Malek_::Malek_Necibi
; :*:Malek@::Malek@Necibi.us
; HotStrings - End

; Hotkey Command Remaps - Begin
Hotkey, IfWinActive, ahk_exe chrome.exe ; Fix Tab Number Selection with Chrome Tab Groups
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

; Global Variables - Start
BT_Devices := [   ["Powerbeats Pro"     , ""]                       ; 1
                , ["Malek's QC35"       , ""]                       ; 2
                , ["Tribit Stormbox"    , ""]                       ; 3
                , ["TOZO-T10 (Black)"   , "58:fc:c6:39:ae:0a"]      ; 4 : MAC Address b/c identical device names
                , ["TOZO-T10 (White)"   , "58:fc:c6:bc:27:58"]  ]   ; 5
; Global Variables - End

return

; Global Remaps - Begin
<!x::
    saveTitleMatchMode := A_TitleMatchMode
    SetTitleMatchMode, 2
    DetectHiddenWindows, On
    WinGet, MiscMacroIDs, List, MiscMacro.ahk - AutoHotkey
    ; WinGet, numInstances, Count, MiscMacro.ahk - AutoHotkey
    numInstances := MiscMacroIDs    ; w/o trailing integer == size of the pseudo-array
    Loop, %numInstances% {
        ; NOTE: Next line is weird and easy to misunderstand
        ; Dynamic Variable Naming
        ; (1) set the VALUE of currentID to the NAME of another variable
        ;     MiscMacroIDs := 0x123456
        ;     currentID := "MiscMacroIDs4"
        ; (2) set the VALUE of currentID to the VALUE of the variable name currentID is possesses
        ;     currentID := MiscMacroIDs4
        ;     currentID now equals 0x123456
        ; currentID = % MiscMacroIDs%A_Index%
        ; currentID := MiscMacroIDs%A_Index%    ; Equivalent to line above
        ; WinGet, MiscMacroPID, PID, ahk_id %currentID%
        
        ; See above comment. Additionally merged the variable declaration and command call
        WinGet, MiscMacroPID, PID, % "ahk_id " . MiscMacroIDs%A_Index%
        Run, taskkill.exe /F /PID %MiscMacroPID%,, min
    }
    Tooltip(-1, "Closing all MiscMacro instances...")
    WinWaitClose, MiscMacro.ahk - AutoHotkey,,10
    if ErrorLevel {
        Tooltip(,"ERROR: Failed to close MiscMacro")
    } else {
        Tooltip(2000, numInstances " MiscMacro instance(s) closed")
        Tray_Refresh()  ; Automated Dead Tray Icon remover
    }
    SetTitleMatchMode, %saveTitleMatchMode%
    return
    
^+#!x:: ; Force Pause and Suspend All AHK Scripts
    Suspend, Permit
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
^+!e::RunAsUser("C:\Program Files\Notepad++\notepad++.exe", """" . A_ScriptFullPath . """") ; Edit this script in Notepad++
^+#!e::     ; Temporarily ignore this script
    Suspend, Permit
    ; Suspend MUST be the first line or AHK wont listen for it
    if (A_IsSuspended != A_IsPaused) {
        ; If only 1 enabled, assume safety : enable both
        Suspend, On
        Pause, On, 1
    } else {
        ; Base case, toggle both together
        Suspend, Toggle
        Pause, Toggle, 1
    }
    return
^+!n::RunAsUser("C:\Program Files\Notepad++\notepad++.exe") ; Launch Notepad++
^+#n::
    RunAsUser("C:\Program Files\Notepad++\notepad++.exe")   ; Launch Notepad++ AND Create New  Page
    WinWaitActive, ahk_class Notepad++,, 5
    if !ErrorLevel
        Send !fn
    return

^+!p::RunAsUser("C:\Program Files\Notepad++\notepad++.exe", "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt") ; View PowerShell History
^+#s::oneRun("ahk_exe SpotifyLyrics.exe", Malek . "SpotifyLyrics.exe")

>^Esc::Goto, NoInput        ; Launch NoInput
; ^+#y::Goto, YouTubeSpeed    ; Launch YouTubeSpeed

; ^+#t::Goto, TechKeys ; Run TechKeys Macro Remap
; ^+#!t::return ; Run, notepad++.exe %Malek%\TechKeys.ahk ; Edit TechKeys Mappings

; Force Connect Bluetooth device
; Using global variable BT_Devices (set on launch)
^+#1::
^+#2::
^+#3::
^+#4::
^+#5::
    bt_id := SubStr(A_ThisHotkey, 0)        ; Just use the number digit
    bt_device := BT_Devices[bt_id]
    bt_name := bt_device[1]
    bt_mac  := bt_device[2]
    ConnectBT(bt_name, bt_mac)
    return
^+#0::  ; Fix Occasional Bug, Display all the id's
    ; TODO : only compute BT_Names once
    BT_Names := ""
    For bt_id, bt_device in BT_Devices {
        BT_Names := BT_Names . bt_id . " : " . bt_device[1] . "`r`n"
    }
    ConnectBT("","")
    ToolTip(2500, BT_Names)
    return

; Open/Resume Calculator, limit number of instances
$>!\::
$>^\::
$>^>!\::oneRun("Calculator","calc.exe",, "Calculator")

; Fine Brightness Control
$^F6::BrightnessSetter.SetBrightness(-1)
$^F7::BrightnessSetter.SetBrightness(+1)
~$+F6::
    ToolTip(,"WARNING: Shift Deprecated" "`r`n" "-1 : Ctrl+F6" "`r`n" "-3 : Ctrl+Shift+F6")
    Sleep 250 ; dissuade
    BrightnessSetter.SetBrightness(-2)
    return
~$+F7::
    ToolTip(,"WARNING: Shift Deprecated" "`r`n" "+1 : Ctrl+F7" "`r`n" "+3 : Ctrl+Shift+F7")
    Sleep 250 ; dissuade
    BrightnessSetter.SetBrightness(+2)
    return
$^+F6::BrightnessSetter.SetBrightness(-3)
$^+F7::BrightnessSetter.SetBrightness(+3)

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

; MiscMacro (for quick temporary remaps/scripts)
^+#m::RunAsUser(A_AhkPath, MMPath)                                  ; (Re)Start MiscMacro
; +#m::return                                                       ; Avoid common misclick
^+!m::RunAsUser("C:\Program Files\Notepad++\notepad++.exe", MMPath) ; Edit MiscMacro

$Insert::return ; Ignore accidental Insert

; Custom Window Snap
#!Up::WindowSnap(2, 1, 1, 1)    ; Snap to top half
#!Down::WindowSnap(2, 1, 2, 1)  ; Snap to bottom half

; PowerToys 
$#r::Send !{space}
$!r::Send #r

; Disable built-in Office Shortcut
#^!Shift::
#^+Alt::
#!+Ctrl::
^!+LWin::
^!+RWin::
    Suspend, Permit     ; Even when script disabled
    Send {Blind}{vkFF}
    return

; Global Remaps - End

; Conditional Remaps - Begin
#If WinActive("ahk_exe explorer.exe")
AppsKey:: ; Extended Context Menu (e.g. Open Linux shell here)
RButton::
    SendInput {shift down}{%A_ThisHotkey%}{shift up}
    return
^+#=::SendInput {AppsKey}n{Left}{Enter}{Esc 2} ; Edit selection with Notepad++
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
            bashDrive := RegExReplace(bashDrive, ":", "")   ; C:\ -> /mnt/c
            if ( 1 == StrLen(bashDrive)) {  ; Limit to mounted drives
                bashDir := StrReplace(SubStr(fileDir, InStr(fileDir,":") + 1),"\","/")
                bashDir = '/mnt/%bashDrive%%bashDir%'   ; merge and escape
                ; pathToBash(filePath)  ; Removed b/c breaks SplitPath compatibility
                ; if (fileExt == "pdf") {   ; limit to pdfs (no images)
                    inputFile = '%fileName%'    ; escape file name
                    ; outputFile := fileNameNoExt . "_ocr." . fileExt
                    ; outputFile = '%outputFile%')
                    outputFile = '%fileNameNoExt%_ocr.pdf'  ; escape file name, set extension
                    outputTextFile = '%fileNameNoExt%_ocr.txt'  ; escape file name, set extension
                    
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
;               }
            }
        }
    } else {
        MsgBox ERROR: Unable to get File-Path from Clipboard (%ErrorLevel%)
    }
    Clipboard := ClipSave
    ClipSave := ""
    ; Tooltip(5000, "searchable pdf")
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

; https://support.google.com/chrome/answer/157179 ; Chrome keyboard shortcuts
#If WinActive("ahk_exe chrome.exe") ; Google Chrome
^+#l::SendInput ^+x
~Rbutton::  ; Duplicate Tab shortcut (Tab RButton + d within 1.5 seconds)
    MouseGetPos,, yPos
    if (yPos <= 61) {   ; right clicked on a tab selector
        Hotkey, IfWinActive, ahk_exe chrome.exe
        Hotkey, d, DuplicateTab
        Hotkey, d, On
        SetTimer, ClearDuplicateTabHotkey, -1000
    }
    return
:*b0:ahk::+{left 3}{backspace}autohotkey
; $^PgUp::^+Tab ; Fix tab switch in pdf's
; $^PgDn::^Tab
$>!PgDn::SendInput ^{Tab} ; ^{PgDn} ; Fix common mistake when changing tab
$>!PgUp::SendInput ^+{Tab} ; ^(PgUp}
; $^+PgUp::Send ^l{F6}^{Left}^l+{F6} ; Shift current tab position
; $^+PgDn::Send ^l{F6}^{Right}^l+{F6}
; $>!LButton::SendInput >^{LButton}
$^+r::SendInput ^+t


#If WinActive("ahk_exe winword.exe") or WinActive("ahk_exe powerpnt.exe")
^PgDn::^Right   ; XPS Keyboard minor grievance
^PgUp::^Left
<^Backspace::
    ; Make Ctrl+Backspace work the same as everywhere else: spaces don't count as full words
    BatchSave := A_BatchLines
    KeySave := A_KeyDelay
    ClipSave := ClipboardAll
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
    ClipSave := ""
    ; hacky fix to avoid modifiers sticking on
    Send {LShift}{RShift}{LCtrl}{RCtrl}
    Send {LShift}
    Send {RShift}
    Send {LCtrl}
    Send {RCtrl}
    Send {LShift}{RShift}{LCtrl}{RCtrl}
    return
^.::Send *{Tab}     ; bullet point
<^f::Send {Esc}^f

#If WinActive("ahk_exe Arduino IDE.exe")
^q::    ; Avoid accidentally closing Arduino
^w::
    Tooltip(, "You almost closed the Arduino IDE!")
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
    if !ErrorLevel and FileExist(Clipboard) {   ; Open file location instead of launching file
        Send {Alt}jso
    } else {
        Send {Enter}
    }
    Clipboard := ClipSave
    ClipSave := ""
    return

#If WinActive("ahk_exe PowerToys.PowerLauncher.exe") ; Remap Run commands
^+#=::SendInput ^+e ; Open file path

; Fix Launching PowerToys Run from Search Bar
#If WinActive("ahk_exe SearchApp.exe")
$#r::Send {Esc}!{Space}

; Click to Play/Pause in VLC
#If WinExist("ahk_exe vlc.exe")
~LButton::
    MouseGetPos ,,,, This_ClassNN
    if(InStr(This_ClassNN, "VLC video output")) {
        Send {Media_Play_Pause}
        ; Sleep 100
        ; Send {Space}
    }
    return

; Youtube Fine Rewind/Fast-Forward
; #If WinActive("ahk_class Chrome_WidgetWin_1") && WinActive("YouTube - Google Chrome")
#If WinActive("ahk_exe chrome.exe") && WinActive("YouTube - Google Chrome")
+j::        ; -2.5
+l::        ; +2.5
+Left::     ; -1.25
+Right::    ; +1.25
    ThisKey := SubStr(A_ThisHotkey, 2) ; Strip leading modifier (+) from keyname
    SendInput +{, 3}{%ThisKey%}+{. 3}
    return



#If
; Conditional Remaps - End
; Remaps - End


; Functions - Begin
ConnectBT(DeviceName := "", MAC := "") { ; Input "" to fix issues with Connect Menu
    ToolTip(, DeviceName)
    ; Turn on Bluetooth
    btScriptPath := A_WorkingDir . "\Files\scripts\bluetooth.ps1"
    if ( FileExist(btScriptPath) ) {
        Run, powershell.exe -file "%btScriptPath%" -BluetoothStatus On,, Hide
        Sleep 100
    } else {
        ToolTip(, "Powershell Bluetooth Script missing")
        Sleep 1000
    }
    
    if ("" == MAC) {
        ; Use Windows Bluetooth Devices Menu
        if ("" != DeviceName && WinActive("CONNECT") && WinActive("ahk_class Windows.UI.Core.CoreWindow")) {
            ; If Connect Menu already open, safely close it
            ConnectBT("")
            Sleep 500
        }
        
        ; Open Quick Connect Menu
        ; Send #k
        Run, ms-settings-connectabledevices:devicediscovery
        WinWaitActive, CONNECT,, 1
        if ErrorLevel {
            ToolTip(1500, "ConnectBT() Error: Couldn't open CONNECT QuickMenu")
            ; Optional, open Bluetooth Settings menu if Connect QuickMenu doesn't open
            ; if ("" != DeviceName)
                ; Run bthprops.cpl
            return
        }
        
        ; Fixes Connect QuickMenu issues
        if ("" == DeviceName) {
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
    
    } else {
        ; Use Bluetooth Command Line Tools (via MAC address)
        
        ToolTip(3000, "This may take over 30 seconds...`r`n" . DeviceName)
        RunWait, "C:\Program Files (x86)\Bluetooth Command Line Tools\bin\btcom.exe" -b'%MAC%' -r -s110b,, Hide
        RunWait, "C:\Program Files (x86)\Bluetooth Command Line Tools\bin\btcom.exe" -b'%MAC%' -c -s110b,, Hide
    }
    
    return
}

oneRun(title, runPath, matchMode:=3, text:="") {
    saveTitleMatchMode := A_TitleMatchMode
    SetTitleMatchMode, %matchMode%
    if WinExist(title, text)
        WinActivate
    else
        RunAsUser("""" . runPath . """")
        ; Run, %runPath%
    SetTitleMatchMode, %saveTitleMatchMode%
    return
}


; Replaced with Brightness.ahk : BrightnessSetter
;
; setBrightness(level := 50) { ; range = 5-100
;     minBrightness := 5  ; levels below this are equivalent
;     maxBrightness := 100
;     
;     if (level < minBrightness)
;         level := minBrightness
;         
;     else if (level > maxBrightness)
;         level := maxBrightness
;     
;     service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
;     monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")
;     
;     for i in monMethods {
;         i.WmiSetBrightness(1, level)
;     }
; }
; 
; getBrightness() {
;     service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
;     monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE")
;     
;     ; if monitors[proc]
;     
;     for i in monitors { ; only reading from 1st monitor, but for-loop still needed
;         return i.CurrentBrightness
;     }
; }
; 
; adjustBrightness(delta) { ; returns new brightness
;     current := getBrightness()
;     newVal := current + delta
;     setBrightness(newVal)
;     realVal := getBrightness()
;     if (realVal != newVal) {
;         dir := (delta>0) - (delta<0)
;         if ((realVal < newVal) && (dir == 1))
;             setBrightness(newVal+1)
;             
;         else if ((realVal > newVal) && (dir == -1))
;             setBrightness(newVal-1)
;     }
;     return getBrightness()
; }
; 


; returns 0: success, otherwise: failure
; verifyIdentity() {
;     
;     static IUserConsentVerifierStatics, UserConsentVerifierAvailability
;     
;     if (UserConsentVerifierAvailability = "") { ; Only Instantiate Class Once
;         CreateClass("Windows.Security.Credentials.UI.UserConsentVerifier", IUserConsentVerifier := "{AF4F3F91-564C-4DDC-B8B5-973447627C65}", IUserConsentVerifierStatics)
;         DllCall(NumGet(NumGet(IUserConsentVerifierStatics+0)+6*A_PtrSize), "ptr", IUserConsentVerifierStatics, "ptr*", UserConsentVerifierAvailability)   ; CheckAvailabilityAsync()
;         WaitForAsync(UserConsentVerifierAvailability)
;     }
;     
;     if (UserConsentVerifierAvailability == 0) { ; Obtaining User Consent is Possible
;         CreateHString("For security, please verify your identity to continue.", verificationHString)
;         DllCall(NumGet(NumGet(IUserConsentVerifierStatics+0)+7*A_PtrSize), "ptr", IUserConsentVerifierStatics, "ptr", verificationHString, "ptr*", UserConsentVerificationResult)   ; RequestVerificationAsync(string)
;         WaitForAsync(UserConsentVerificationResult)
;         DeleteHString(verificationHString)
;     
;     } else 
;         return UserConsentVerifierAvailability
;     
;     return UserConsentVerificationResult
; }


; Convert to bash (ex: "C:\Users\Folder Name" -> '/mnt/c/Users/Folder Name')
pathToBash(filePath) {
    bashPath := ""
    SplitPath, % filePath,,,,, fileDrive
    if ("" != fileDrive) {  ; limit to mounted drives only 
        StringLower, bashDrive, fileDrive
        bashDrive := RegExReplace(bashDrive, ":", "")   ; C:\ -> /mnt/c
        if ( 1 == StrLen(bashDrive)) {  ; Limit to local files only
            bashPath := StrReplace(SubStr(filePath, InStr(filePath,":") + 1),"\","/")   ; remove drive, flip slashes
            ; bashPath = '/mnt/%bashDrive%%bashPath%'   ; merge and escape
            bashPath = /mnt/%bashDrive%%bashPath%   ; merge
        }
    }
    return bashPath
}


; time: milliseconds to display tooltip, -1 for infinite.
Tooltip(time:=1500, message:="", X:="", Y:="", WhichToolTip:="")
{
    if time is not number   ; If Var is Type doesn't allow inline bracing
    {
        ; Throw error, but still show Tooltip message (Recursive Call)
        Tooltip(,"Tooltip() WARNING: Invalid Time Provided (" time ")`r`n" . message, X, Y, WhichToolTip)
    
    } else {
        Tooltip, %message%, %X%, %Y%, %WhichToolTip%
        if (time >= 0) {    ; Persist if time is negative
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
    Run, "Files\lib\NoInput.ahk"    ; RunAsUser exception
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


FixCursor:
fixCursorScriptPath := A_WorkingDir . "\Files\lib\FixCursor.ps1"
if ( FileExist(fixCursorScriptPath) ) {
    Run, powershell.exe -file "%fixCursorScriptPath%" ,, Hide
}
return


YouTubeSpeed:
if FileExist("YouTubeSpeed.ahk")
    RunAsUser(A_AhkPath, """" . AHK . "\XPS Programs\YouTubeSpeed.ahk" . """")
return


ResetMisc:
if FileExist(MMPath) {
    InputBox, MMBName, MiscMacro Backup, Please name this backup:
    if (!ErrorLevel) {
        if MMBName
            MMBName := "." . RegExReplace(MMBName, "[\?<>/\\\*""|: ]", "")  ; Clean/Strip filename
        FormatTime, FileDateTime,, MM-dd-yyyy-hhmmtt
        MMBPath := Malek . "MiscMacro Backups\MiscMacro." . FileDateTime . MMBName . ".bkp.ahk"
        FileCopy, %MMPath%, %MMBPath%
        FileRecycle, %MMPath%
        FormatTime, HeaderDateTime,, MM/dd/yyyy hh:mm tt
        ; Expand A_ScriptDir because MiscMacro path not relative to DefaultHeader-v3.ahk
        FileAppend, `; Created - %HeaderDateTime%`r`n#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.1.ahk`r`nHeader:`r`nFinishHeader(`0)`r`nFinishHeader(`1)`r`n`r`n`r`n`r`n`r`n`#If`r`n`; ``::ExitApp`r`n`r`nRemoveToolTip:`r`nTooltip`r`nreturn, %MMPath%
        if (!ErrorLevel)
            MsgBox Reset Successful!`n`nBackup Created at:`n%MMBPath%
    }
    ; Run, %Malek%\MiscMacro.ahk
}
return


MousePortal:    ; Teleport mouse cursor between monitors in the corner
SysGet, numDisplays, 80 ; SM_CMONITORS ; Get number of displays
if (numDisplays = 1)
    return
Loop, % numDisplays ; Get pixel bounds for each displays
    SysGet, display%A_Index%, Monitor, %A_Index%
; 'Convert' to portal pixels
xDisplay1 := display1Right-1, yDisplay1 := display1Top ; (Primary Display)
xDisplay2 := display2Left, yDisplay2 := display2Bottom-1 ; (Secondary Display)
; Old Method, Hardcoded Values
; xDisplay1 := 1919, yDisplay1 := 0 ; (XPS Display)
; xDisplay2 := 1818, yDisplay2 := -541 ; (BenQ 4K Monitor)
; xDisplay2 := 1874, yDisplay2 := -1080 ; (Misc)
DllCall("user32.dll\GetCursorPos", Int, &CursorPos) ; Get current cursor position
x := NumGet(CursorPos, 0, "Int")
y := NumGet(CursorPos, 4, "Int")
if (x = xDisplay1 and y = yDisplay1){   ; If at portal 1
    DllCall("SetCursorPos", "int", xDisplay2, "int", yDisplay2) ; Teleport to portal 2
} else if (x = xDisplay2 and y = yDisplay2) { ; If at portal 2
    DllCall("SetCursorPos", "int", xDisplay1, "int", yDisplay1) ; Teleport to portal 1
}
return


ChromeGroupsTabCount:
tabNum := SubStr(A_ThisHotkey,2)
Send ^9^{PgDn %tabNum%}
return


DuplicateTab:
SendInput {Down 6}
Send +{Enter}
SetTimer, ClearDuplicateTabHotkey, Off
GoSub, ClearDuplicateTabHotkey
return

ClearDuplicateTabHotkey:
Hotkey, d, Off
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
modifiers := ["RShift", "LShift", "RCtrl", "LCtrl", "RWin", "LWin", "RAlt", "LAlt"]
ToolTipChanged := false
Loop {
    Sleep 5
    stuckKeys := ""
    for i, key in modifiers {
        key_L := GetKeyState(key)       ; Logical state
        key_P := GetKeyState(key, "P")  ; Physical state
        if (key_L != key_P) {
            SetTimer,, Off  ; Restart testing immediately 
            stuckKeys := stuckKeys . key . "`n"
        }
    }
    if ("" != stuckKeys) {
        Tooltip(, stuckKeys)    ; Look into creating multiple tooltips with id's
        ToolTipChanged := true
    }
} Until ("" = stuckKeys)
if (ToolTipChanged) {
    Tooltip(0, "")
}
SetTimer,, On   ; Resume slower periodic  testing
return


; Reset Focus Assist (Do Not Disturb) to show all notifications
ClearFocusAssist:
Send #b{left}{appskey}fo
Sleep 50
Send !{Esc}
Tooltip(2500, "Focus Assistant: Cleared")
return


Nothing:
return


RemoveToolTip:
RemoveToolTip():
ToolTip
return
; Labels - End
