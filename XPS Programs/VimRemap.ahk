#include %A_ScriptDir%\DefaultHeader-v2.ahk
Header:
FinishHeader(4)
SetTitleMatchMode, 2
FinishHeader(5)

#IfWinActive mnygp@clark-r630-login-node907 ; VIM Remaps
^s::SendInput {Esc 4}:w{Enter}i{Right}
^w::SendInput {Esc 4}:wq{Enter}
$^Left::SendInput {Esc 4}bi
$^Right::SendInput {Esc 4}{Right}wi
^Down::SendInput ^t{Down}{Home}
+Down::SendInput {Esc 4}{Home}wi{BackSpace}{Down}{Home}
^z::SendInput {Esc 4}{u}i
^u::SendInput {Esc 4}^{r}i
^f::SendInput {Esc 4}?
^g::SendInput {Esc 4}:nohlsearch{Enter}i{Right}
:*:ccc::clear && clear && compile n-lab10.edited.c && ./a.out lab10.dat{Space}