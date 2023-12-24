#Persistent
ClipBack:=Clipboard
Gui, +AlwaysOnTop -SysMenu
Gui, Margin, 20, 20
Gui, Font, s18 Bold, Verdana
;Uncomment the following line to suppress System Sound Event DING.WAV!
Gui, Add, Listview, x20 y20 w90 h33 vDummyListView
Gui, Add, Text    , x20 y20 w90 h33 c686868 +0x200 +Center +Border vVKCODE
Gui, Add, Text, x+5        w400 h33 c3D3D30 +0x200 vVKNAME
Gui, Show, , Virtual-Key Code Finder .. Press any key!

Loop {
      KeyPressed:=InputKey()
      IniRead, VK, VK_NAMES.INI, VirtualKeyName, %KeyPressed%, %A_Space%
      GuiControl,,VKNAME, %VK%
      StringRight, Code, KeyPressed, 2
      Clipboard = % "VK" Code
      GuiControl,,VKCODE, % "VK" Code
     }
Return

GuiEscape:
 Clipboard:=ClipBack
 ExitApp
Return

InputKey(Duration=0, Prefix="")    {
 Global A_KBI_Timeleft
 IfEqual,Prefix,, SetEnv,Prefix,0x
 A_FI:=A_FormatInteger
 TC:=A_TickCount 
 VarSetCapacity(lpKeyState,256,0)    
 DllCall("SetKeyboardState", UInt,&lpKeyState)
 Loop {
        DllCall("GetKeyboardState", UInt,&lpKeyState)
        Loop, 256 {
                    Int:=*(&lpkeystate+(A_Index-1))
                    If (Int>=0x80)
                      {
                        VK_CODE:=A_Index-1      
                        Break
                      }
                  }
        IfNotEqual,VK_CODE,, Break
        A_KBI_Timeleft:=Round((Duration-(A_TickCount-TC))/1000)
        If (Duration AND (A_TickCount-TC>=Duration))
           Break 
        Sleep 20
      }
IfEqual,VK_CODE,, Return, VK_CODE
 SetFormat, Integer, Hex
 VK_CODE+=0
 StringReplace, VK_CODE, VK_CODE, 0x, 0x0
 StringRight, VK_CODE, VK_CODE, 2
 StringUpper, VK_CODE, VK_CODE
 SetFormat, Integer, %A_FI%
Retval=%Prefix%%VK_CODE%
Return RetVal
}