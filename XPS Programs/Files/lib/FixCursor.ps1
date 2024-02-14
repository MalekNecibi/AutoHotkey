# Re-apply the currently selected Mouse Cursor profile
# Useful because sometimes mouse cursor disappears in front of text input field (even when Windows setting disabled)

# https://devblogs.microsoft.com/scripting/use-powershell-to-change-the-mouse-pointer-scheme/
# https://stackoverflow.com/a/28187071
# https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa?redirectedfrom=MSDN
# https://www.leeholmes.com/powershell-pinvoke-walkthrough/


$CSharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
             uint uiAction,
             uint uiParam,
             uint pvParam,
             uint fWinIni);
'@

$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru

$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)
