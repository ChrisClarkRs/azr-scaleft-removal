#Add Linux Removal
<#
    .SYNOPSIS
    Executes uninstall on Scaleft agent, gatheres and removes scaleft assocauted accounts 
       
    .DESCRIPTION
    Full description: Script checks if Scaleft is installed, if so removes applciation. Checks for Scaleft Users if present removed.
    supported: Yes
    Prerequisites: No
    Makes changes: Yes

    .EXAMPLE
    Full command: Get-ScaleftUsers and Remove-Scaleft
       
    .OUTPUTS
    No Scaleft Users from $ComputerName
    Scaleft Users removed from $ComputerName
    Scaleft Service not found $ComputerName
    Scaleft Removed $ComputerName

        
    .NOTES
    Minimum OS: 2012 
    Minimum PoSh: 4.0
    Version Table:
    Version :: Author             :: Live Date   :: JIRA     :: QC          :: Description
    -----------------------------------------------------------------------------------------------------------
    1.0     :: Chris Clark        :: 21-September-2018 ::   ::      :: Remove Scaleft and assocated users
#>
function Get-ScaleftUsers {
    try {
        $ComputerName = $env:computername 
        #get list of sft users excluding current
        $sftusers = (Get-WmiObject -Class Win32_UserAccount | Where-Object {$_.name -match "rackspacesft"}).name
        if ($sftusers -eq $Null) {
            Write-Output "No Scaleft Users from $ComputerName"
        }
        Else {
            [ADSI]$server = "WinNT://$ComputerName"
            foreach ($User in $sftusers) {
                $server.delete("user", $user)}           
            }
        }
    catch {
        #Information to be added to private comment in ticket when unknown error occurs
        $ScriptDbPayloadErr = $null
        $ScriptDbPayloadErr += Write-Output "Script failed to run`n"
        $ScriptDbPayloadErr += Write-Output = "Powershell exception :: Line# $($_.InvocationInfo.ScriptLineNumber) :: $($_.Exception.Message)"
        return $ScriptDbPayloadErr
    }
}

function Remove-Scaleft {
    try {
        $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "ScaleFT"}  -ErrorAction SilentlyContinue
        $ComputerName = $env:computername
        if ($app -eq $null) {
            write-output "Scaleft Service not found $ComputerName"
        }
        Else {
            #stop service
            Stop-Service -Name "scaleft-server-tools" -ErrorAction SilentlyContinue
            #uninstall
            $getreturn = $app.Uninstall()
            Write-Output "Scaleft Removed $ComputerName"
        }
    }
    catch {
        #Information to be added to private comment in ticket when unknown error occurs
        $ScriptDbPayloadErr = $null
        $ScriptDbPayloadErr += Write-Output "Script failed to run`n"
        $ScriptDbPayloadErr += Write-Output = "Powershell exception :: Line# $($_.InvocationInfo.ScriptLineNumber) :: $($_.Exception.Message)"
        return $ScriptDbPayloadErr
    }
}
Get-ScaleftUsers
Remove-Scaleft