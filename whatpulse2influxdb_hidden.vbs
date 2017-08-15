Set fso = CreateObject("Scripting.FileSystemObject")
thisScriptFolder = fso.GetParentFolderName(WScript.ScriptFullName) 
Set shell = CreateObject("WScript.Shell")
shell.Run "powershell.exe -nologo -command """ + thisScriptFolder + "\whatpulse2influxdb.ps1""", 0
