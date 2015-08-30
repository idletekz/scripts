﻿<#
.Synopsis
    Installs SQLPS module and dependencies.

.Link
    Start-Process

.Link
    Invoke-WebRequest

.Link
    http://www.microsoft.com/en-us/download/details.aspx?id=42295
#>

#requires -version 3
#requires -RunAsAdministrator
[CmdletBinding(ConfirmImpact='High',SupportsShouldProcess=$true)]Param()
if(!$PSCmdlet.ShouldProcess('SQLPS module','install')) {return}
Push-Location $env:Temp
foreach($msi in @('SQLSysClrTypes','SharedManagementObjects','PowerShellTools'))
{
    if(Test-Path "$msi.msi'") {}
    elseif(($PSScriptRoot -ne $env:Temp) -and (Test-Path "$PSScriptRoot\PowerShellTools.msi")) {Copy-Item "$PSScriptRoot\*.msi"}
    else {Invoke-WebRequest "http://download.microsoft.com/download/1/3/0/13089488-91FC-4E22-AD68-5BE58BD5C014/ENU/x64/$msi.msi" -OutFile "$msi.msi"}
    Start-Process -FilePath msiexec -ArgumentList '/i',"$msi.msi",'/passive','/norestart','INSTALLLEVEL=32767' -Wait -NoNewWindow
    Remove-Item "$msi.msi"
}
Pop-Location
