Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "RunWindows.bat Background" & Chr(34), 0
Set WshShell = Nothing