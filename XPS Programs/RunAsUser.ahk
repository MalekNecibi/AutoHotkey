
; command := "C:\Windows\System32\cmd.exe"
; RunAsUser(command, arguments, path)


AhkFullPath()
{
	ahkPath := ""
	if !A_IsCompiled {
		cl_args := DllCall("GetCommandLine", "str")
		if cl_args {
			StringMid, ahkPath, cl_args, 2, InStr( cl_args, """", true, 2 )-2
		}
	}
	
	; Only works if AHK installer was used
	if !ahkPath {
		regread, ahkPath, HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AutoHotkey.exe"
	}
	
	return ahkPath
}

RunAhkScript(scriptPath)
{
	command := AhkFullPath()
	SplitPath, command,, path
	RunAsUser(command, scriptPath, path)
}

RunAsUser(Target, Arguments:="", WorkingDirectory:="")
{
   static TASK_TRIGGER_REGISTRATION := 7   ; trigger on registration. 
   static TASK_ACTION_EXEC := 0  ; specifies an executable action. 
   static TASK_CREATE := 2
   static TASK_RUNLEVEL_LUA := 0
   static TASK_LOGON_INTERACTIVE_TOKEN := 3
   objService := ComObjCreate("Schedule.Service") 
   objService.Connect() 

   objFolder := objService.GetFolder("\")
   folders := objFolder.GetFolders(0)
   ; Loop % Array.MaxIndex()   ; More traditional approach.
	; for folder in folders  ; Enumeration is the recommended approach in most cases.
	; {
		; MsgBox % folder
	; }
   objTaskDefinition := objService.NewTask(0) 

   principal := objTaskDefinition.Principal 
   principal.LogonType := TASK_LOGON_INTERACTIVE_TOKEN    ; Set the logon type to TASK_LOGON_PASSWORD 
   principal.RunLevel := TASK_RUNLEVEL_LUA  ; Tasks will be run with the least privileges. 

   colTasks := objTaskDefinition.Triggers
   objTrigger := colTasks.Create(TASK_TRIGGER_REGISTRATION) 
   endTime += 3, Minutes  ;end time = 1 minutes from now 
   FormatTime,endTime,%endTime%,yyyy-MM-ddTHH`:mm`:ss
   objTrigger.EndBoundary := endTime
   colActions := objTaskDefinition.Actions 
   objAction := colActions.Create(TASK_ACTION_EXEC) 
   objAction.ID := "7plus run" 
   objAction.Path := Target
   objAction.Arguments := Arguments
   objAction.WorkingDirectory := WorkingDirectory ? WorkingDirectory : A_WorkingDir
   objInfo := objTaskDefinition.RegistrationInfo
   objInfo.Author := "7plus" 
   objInfo.Description := "Runs a program as non-elevated user" 
   objSettings := objTaskDefinition.Settings 
   objSettings.Enabled := True 
   objSettings.Hidden := False 
   objSettings.DeleteExpiredTaskAfter := "PT0S"
   objSettings.StartWhenAvailable := True 
   objSettings.ExecutionTimeLimit := "PT0S"
   objSettings.DisallowStartIfOnBatteries := False
   objSettings.StopIfGoingOnBatteries := False
   objFolder.RegisterTaskDefinition("", objTaskDefinition, TASK_CREATE , "", "", TASK_LOGON_INTERACTIVE_TOKEN ) 
}