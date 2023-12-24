; Malek Necibi
; IFEO Program Siphon
; 04/25/2020

#SingleInstance, off
#NoTrayIcon
#NoEnv

parameters := ""
destination := A_Args[1]

for n, arg in A_Args {
	
	if !(n=1 OR n=2) ; exclude first 2 arguments (Source, Destination filenames)
		parameters = %parameters% "%arg%"
}

; MsgBox Run, %destination% %parameters%

if A_Args.Length()
	Run, %destination% %parameters%