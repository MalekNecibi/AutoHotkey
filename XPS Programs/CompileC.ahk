; Created by: Malek Necibi
; Used to quickly compile/run files via Ubuntu subsystem for Linus



; ----------------------- ;
; folderName = ~/cs2050/Labs/Lab15/Prelab15
folderName = ~/Mizzou/5\ -\ Fall\ 2021/CS\ 4050\ -\ Algorithms/2\ -\ Homework/HW1/
fileName = q1.c
command = cd %folderName% && ~/.PATH/compiler %fileName% `; bash
; ----------------------- ;

; ----------------------- ;
; folderName = ~/cs2050/Labs/Lab15
; fileName0 = main.c
; fileName1 = lab15_f_Malek.c
; command = cd %folderName% && ~/.PATH/compiler %fileName0% %fileName1%`; bash
; ----------------------- ;

; ----------------------- ;
; folderName = ~/WSL/C++
; fileName = test03.ncpp
; command = cd %folderName% && ~/.PATH/compilerCPP %fileName% `; bash
; ----------------------- ;



Winkill, ahk_exe ubuntu.exe

Run ubuntu run %command%

Exit