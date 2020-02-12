#Shutdown server	
function VM_Shutdown($server){

	$vCenter1="vCenter1.sub1.domain.com" 
	$vCenter2="vCenter2.sub2.domain.com"

	
	#Checking vCenter1
	try{
		write-host "Checking Seattle vCenter"
		Connect-VIServer $seaVcenter
		Get-VM -Name $server | Stop-VM -Confirm:$false | Select Name,PowerState, VMHost
		Cleanup_SSH_Sessions
	}

	#Check vCenter2
	Catch [VimException]{
		write-host "Checking Remote vCenter"
		Connect-VIServer $vCenter2
		Get-VM -Name $server | Stop-VM -Confirm:$false | Select Name,PowerState, VMHost
		Cleanup_SSH_Sessions
	}
	Catch{
		Write-Host "Server not found on vCenter1 or vSphere2"
		write-host "Server may be physcial"
	}
	
	return
}
	
