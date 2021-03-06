﻿<#
.Synopsis
    Returns the possible values of the specified enumeration.

.Parameter Type
    The enumeration type name.

.Inputs
    System.Type of an Enum to get the values for.

.Outputs
    System.Management.Automation.PSObject with the Value and Name for each defined
    value of the Enum.

.Example
    Get-EnumValues Management.Automation.ActionPreference

    Value Name
    ----- ----
        0 SilentlyContinue
        1 Stop
        2 Continue
        3 Inquire
        4 Ignore
        5 Suspend

.Example
    Get-EnumValues ConsoleColor

    Value Name
    ----- ----
        0 Black
        1 DarkBlue
        2 DarkGreen
        3 DarkCyan
        4 DarkRed
        5 DarkMagenta
        6 DarkYellow
        7 Gray
        8 DarkGray
        9 Blue
       10 Green
       11 Cyan
       12 Red
       13 Magenta
       14 Yellow
       15 White
#>

#Requires -Version 3
[CmdletBinding()][OutputType([psobject[]])] Param(
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][Type]$Type
)
Process
{
    [enum]::GetValues($Type) |
        % {New-Object PSObject -Property ([ordered]@{Value=[int]$_;Name=[string]$_})}
}
