#REBOOT (Disable/Reboot/Enable) (example: ServerName [-r, -re, -reboot, -restart])
function VM_Reboot($Server){

    $vCenter1="vCenter1.sub1.domain.com" 
    $vCenter2="vCenter2.sub2.domain.com"
	#Checking vCenter1
	try{
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		Connect-VIServer $vCenter1 | Out-Null
		Get-VM -Name $Server | Restart-VM -Confirm:$false | Select Name,PowerState, VMHost
		Disconnect-VIServer -Server $vCenter1 -Confirm:$false
        write-host "Waiting for VM to restart..."
        Start-Sleep -s 15
	}
	catch{
		try{
			$ErrorActionPreference = "Stop"; #Make all errors terminating
			Connect-VIServer $vCenter2 | Out-Null
			Get-VM -Name $Server | Restart-VM -Confirm:$false | Select Name,PowerState, VMHost
			Disconnect-VIServer -Server $vCenter2 -Confirm:$false
            write-host "Waiting for VM to restart..."
            Start-Sleep -s 15
		}
		catch{write-host "Server not found! Server could be physical" -ForegroundColor Yellow}
	 }
	 
	 
	Cleanup_SSH_Sessions | Out-Null

}