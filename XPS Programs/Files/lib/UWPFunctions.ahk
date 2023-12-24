; Malek Necibi
; 03/26/2021
; CREATED BY SOMEONE ELSE ON AHK FORUM, UNABLE TO FIND ORIGINAL 
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=72797&p=314957&hilit=CreateClass#p314957

; Used for UWP/Runtime API calls
; https://github.com/tpn/winsdk-10/tree/master/Include/10.0.16299.0/winrt

CreateClass(string, interface, ByRef Class) {
   CreateHString(string, hString)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
   result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class, "uint")
   if (result != 0) {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      ExitApp
   }
   DeleteHString(hString)
}

CreateHString(string, ByRef hString) {
   DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}

DeleteHString(hString) {
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(ByRef Object) {
   AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
   Loop {
      DllCall(NumGet(NumGet(AsyncInfo+0)+7*A_PtrSize), "ptr", AsyncInfo, "uint*", status)   ; IAsyncInfo.Status
      if (status != 0) {
         if (status != 1) {
            DllCall(NumGet(NumGet(AsyncInfo+0)+8*A_PtrSize), "ptr", AsyncInfo, "uint*", ErrorCode)   ; IAsyncInfo.ErrorCode
            MsgBox AsyncInfo status error: %ErrorCode%
			ObjRelease(Object)
			Object := (ErrorCode == "") ? (-1) : (ErrorCode)
			return
         }
         ObjRelease(AsyncInfo)
         break
      }
      Sleep 10
   }
   DllCall(NumGet(NumGet(Object+0)+8*A_PtrSize), "ptr", Object, "ptr*", ObjectResult)   ; GetResults
   ObjRelease(Object)
   Object := ObjectResult
}