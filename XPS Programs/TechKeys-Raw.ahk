#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.ahk
Header:
#KeyHistory 1
FinishHeader(0)
FinishHeader(1)

; Remaps
^+!F1::
^+!F2::
^+!F3::
^+!F4::
^+!F5::
^+!F6::
	key := SubStr(A_ThisHotKey, 5)
	MacroToolTip(key)
	switch (key) {
		case 1:
			
			return
		
		case 2:
			
			return
		
		case 3:
			
			return
		
		case 4:
			
			return
		
		case 5:
			
			return
		
		case 6:
			
			return
		
		default:
			MsgBox, Error-TechKeys.ahk: Invalid case in switch (%key%)
			return
	}
	return




; Functions
MacroToolTip(n) {
	ToolTip, Key `#%n%
	SetTimer, RemoveToolTip, -1500
}

RemoveToolTip:
ToolTip
return


; Other Remaps
^+!t::Reload