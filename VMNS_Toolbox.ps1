############################################################################################################
#    
#  NOC's vSphere / Netscaler Toolbox!
#  
#  Use: provide the server name you wish to Disable/Enable in the netscaler, or Restart/Shutdown/Power on.
#  ---------------------------------------------------------------------------------------------------------
#
#  Support Arguements: 
#
#  -d(isable)              <- disables server in Netscaler
#  -e(nable)               <- enables  server in Netscaler
#  -r(estart) OR -reboot   <- disable, reboot VM, (wait 15 secs)then enable
#  -s(hutdown) OR -off     <- disable, shutdown VM
#  -on                     <- power on VM, enable in Netscaler
#  
#
#
#  Example (disable in netscaler): 
#     Server> UnderwaterBasketWeavingWeb01 -d 
#  ---------------------------------------------------------------------------------------------------------
#  
#  Requirements: 
#  1) Install powerCLI (VMware-PowerCLI-6.5.0.exe bundled with this script) Check for more recent ver online
#  2) Get-Module -Name VMware* -ListAvailable | Import-Module
#  3) Install-Module -Name Posh-SSH
#  4) Restart powershell ISE         
#  5) During first run you must accept the Netscaler fingerprints when prompted
#
#  **Note: If this is the first time using powershell run the following:
#         Set-ExecutionPolicy Unrestricted 
#         set-item WSMan:\localhost\Client\TrustedHosts *
#
#

#######################################################
#
#  TODO:
#
#     Mulitiple servers (delimited by ':' and ',')
#
#     Bound service group currently shows as "Service" (Out of Service), if server is disabled (check preceeding elements of string for svc group name)
#


param 
( 
[System.Management.Automation.CredentialAttribute()] 
$My_Creds 
)

Import-Module VMware.VimAutomation.Vds 

. "$PSScriptRoot\Modules\Get_Creds.ps1"
. "$PSScriptRoot\Modules\Cleanup_SSH_Sessions.ps1"
. "$PSScriptRoot\Modules\Find_Netscalers.ps1"
. "$PSScriptRoot\Modules\NS_Disable.ps1"
. "$PSScriptRoot\Modules\NS_Enable.ps1"
. "$PSScriptRoot\Modules\VM_Shutdown.ps1"
. "$PSScriptRoot\Modules\VM_PowerOn.ps1"
. "$PSScriptRoot\Modules\VM_Reboot.ps1"
. "$PSScriptRoot\Modules\VM_Screenshot.ps1"

set-PowerCLIConfiguration -InvalidCertificateAction Ignore -confirm:$false | Out-Null

$Netscalers="netscaler1.domain.net", "netscaler2.domain.net","netscaler3.domain.net","netscaler4.domain.net","netscaler5.domain.net","netscaler6.domain.net"
$vCenter1="vcenter1.company.domain.com" 
$vCenter2="vcenter2.company.domain.com"
$Global:My_Creds = Get_Creds




$myLoop=0
While($myLoop -eq 0){
    $NS_Name = ""
    $Node_Name =""
    $Bound_Scalers = New-Object "string[,]" 6,11
    

    write-host "`n`n######################################################################################" -ForegroundColor Green
    $inputRAW = Read-Host -Prompt 'Server'
    $input = $inputRAW.Trim()
    $input = $input.Replace('\s+', ' ') #compress whitespace
    $input = $input.ToLower()
    if(($input.Contains("quit") -eq $true) -or ($input.Contains("exit") -eq $true)){break}

    $input_temp = $input.Split(" ")
    $Server= $input_temp[0].Split(",").Trim()
    $args= $input_temp[1]


    If([string]::IsNullOrEmpty($Server)-eq $false){
        $nodeName, $Bound_Scalers = Find_Netscalers $Server $My_Creds $Netscalers 0

        If($null -ne $args){
            #Disable Node
            If($args.Contains("-d") -eq $true){NS_Disable $nodeName $My_Creds $Bound_Scalers}

            #Enable Node
            ElseIf($args.Contains("-e") -eq $true){NS_Enable $nodeName $My_Creds $Bound_Scalers}

            #Power OFF VM
            ElseIf(($args.Contains("-off") -eq $true) -or ($args.Contains("-shut") -eq $true)){        
                NS_Disable $nodeName $My_Creds $Bound_Scalers
                VM_Shutdown $server
            }
        
            #Power ON VM
            ElseIf($args.Contains("-on") -eq $true){        
                VM_PowerOn $server
                Start-Sleep -s 15
                NS_Enable $nodeName $My_Creds $Bound_Scalers
            }

            #Reboot VM
            ElseIf($args.Contains("-r") -eq $true){        
                NS_Disable $nodeName $My_Creds $Bound_Scalers
                VM_Reboot $server
                NS_Enable $nodeName $My_Creds $Bound_Scalers
            }

            Else{
                write-host "Supplied argument is not valid" -Foreground Red
                return
            }

            #Recheck node state (up/down)
            write-host "`n`nCurrent State:" -Foreground Cyan
            for($x=0; $x -le $Bound_Scalers.GetUpperBound(0); $x++){
                if ($Bound_Scalers[$x,0].length -ne 0){
                    Find_Netscalers $nodeName $My_Creds $Bound_Scalers[$x,0] 1 | Out-Null
                }
            }
        }

        #No Args supplied by user (just return server info/status)
        ElseIf($null -eq $args)
        {   
			#check vCenter1
            try{
                $ErrorActionPreference = "Stop"; #Make all errors terminating
                write-host "`nSeattle VM information:" -ForegroundColor Yellow
                Connect-VIServer $vCenter1
                Get-VM -Name $server | Select VMHost
                #Get-VM -Name $server
                Disconnect-VIServer -Server $vCenter1 -Confirm:$false
            }

            #check vCenter2
            catch{
                try{
                    write-host "`n vCenter2 information:" -ForegroundColor Yellow
                    Connect-VIServer $vCenter2 
                    Get-VM -Name $Server | Select VMHost
                    Disconnect-VIServer -Server $vCenter2 -Confirm:$false
                }
                catch{write-host "vm not found on either vSphere"}
                                
            }
            write-host "Missing arguement - No Action Taken" -ForegroundColor Yellow
        }       
    }
    Else{write-host "Enter a server name!"  -ForegroundColor Yellow}


    }
