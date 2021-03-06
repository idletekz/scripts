﻿<#
.Synopsis
    Collects some useful system hardware and operating system details via WMI.

.Parameter ComputerName
    The computer from which to get WMI details.

.Parameter All
    Get all of the available details, rather than just the most pertinent ones.

.Outputs
    System.Management.Automation.PSObject with properties about the computer:

    * Name: The computer name.
    * Status: The reported computer status name.
    * Manufacturer: The reported computer manufacturer name.
    * Model: The reported computer model name.
    * PrimaryOwnerName: The reported name of the owner of the computer, if available.
    * Memory: The reported memory in the computer, and amount unused.
    * OperatingSystem: The name and type of operating system used by the computer.
    * Processors: CPU hardware detais.
    * Drives: Storage drives found on the computer.
    * Shares: The file shares configured, if any.
    * NetVersions: The versions of .NET on the system.

.Example
    Get-SystemDetails.ps1

    Name             : DEEPTHOUGHT
    Status           : OK
    Manufacturer     : Microsoft Corporation
    Model            : Surface Pro 4
    PrimaryOwnerName : 
    Memory           : 3.93 GiB (25.68 % free)
    OperatingSystem  : Microsoft Windows 10 Pro64-bit  (10.0.14393)
    Processors       : Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz
    Drives           : C: 118 GiB (31.47 % free)
    Shares           : 
    NetVersions      : {v4.6.2+win10ann, v3.5, v2.0.50727, v3.0}
#>

#Requires -Version 3
[CmdletBinding()][OutputType([psobject])] Param(
[Parameter(Position=0,ValueFromRemainingArguments=$true)]
[Alias('CN','Server')][string[]]$ComputerName=$env:COMPUTERNAME,
[Parameter()][switch]$All
)
foreach($computer in $ComputerName)
{
    $wmiargs = @{ ComputerName= $computer }
    $cs = gwmi Win32_ComputerSystem @wmiargs
    $os = gwmi Win32_OperatingSystem @wmiargs
    $value = [ordered]@{}
    if($All)
    {
        $cs.PSObject.Properties |? {!($value.Contains($_.Name)) -and $_.Name -notlike '__*'} |% {$value.Add($_.Name,$_.Value)}
        $os.PSObject.Properties |? {!($value.Contains($_.Name)) -and $_.Name -notlike '__*'} |% {$value.Add($_.Name,$_.Value)}
        $value.TotalPhysicalMemory = Format-ByteUnits $value.TotalPhysicalMemory -si -dot 2 + 
            " ($('{0:p}' -f (1KB*$os.FreePhysicalMemory/$cs.TotalPhysicalMemory)) free)"
        $value.Processors= (gwmi Win32_Processor @wmiargs |
            % Name |
            % {$_ -replace '\s{2,}',' '})
        $value.Drives= (gwmi Win32_Volume @wmiargs |
            ? {$_.DriveType -eq 3 -and $_.DriveLetter -and $_.Capacity} |
            sort DriveLetter |
            % {"$($_.DriveLetter) $(Format-ByteUnits $_.Capacity -si -dot 2) ($('{0:p}' -f ($_.FreeSpace/$_.Capacity)) free)"})
        $value.Shares= (gwmi Win32_Share @wmiargs |
            ? {$_.Type -eq 0} |
            % {"$($_.Name)=$($_.Path)"})
        $value.NetVersions = (Get-NetFrameworkVersions.ps1 $computer)
    }
    else
    {
        $value = [ordered]@{
            Name = $cs.Name
            Status = $cs.Status
            Manufacturer = $cs.Manufacturer
            Model = $cs.Model
            PrimaryOwnerName = $cs.PrimaryOwnerName
            Memory = (Format-ByteUnits $cs.TotalPhysicalMemory -si -dot 2) + 
                " ($('{0:p}' -f (1KB*$os.FreePhysicalMemory/$cs.TotalPhysicalMemory)) free)"
            OperatingSystem = $os.Caption + $(try{ $os.OSArchitecture }catch{''}) + ' ' + $os.CSDVersion + ' (' + $os.Version + ')'
            Processors = (gwmi Win32_Processor @wmiargs |
                % Name |
                % {$_ -replace '\s{2,}',' '})
            Drives = (gwmi Win32_Volume @wmiargs |
                ? {$_.DriveType -eq 3 -and $_.DriveLetter -and $_.Capacity} |
                sort DriveLetter |
                % {"$($_.DriveLetter) $(Format-ByteUnits $_.Capacity -si -dot 2) ($('{0:p}' -f ($_.FreeSpace/$_.Capacity)) free)"})
            Shares= (gwmi Win32_Share @wmiargs |
                ? {$_.Type -eq 0} |
                % {"$($_.Name)=$($_.Path)"})
            NetVersions = (Get-NetFrameworkVersions.ps1 $computer)
        }
    }
    New-Object PSObject -Property $value
}
