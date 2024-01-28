#KeyHistory 0
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Warn  ; Enable warnings to assist with detecting common errors.

message := ""

if (%0% == 0) {
    message := "MsgBox.ahk called with no arguments"
}

for n, param in A_Args
{
    message := message . param . "`r`n"
}

MsgBox, 4096, Message Box (Standalone), %message%

Exit