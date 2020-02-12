#Power ON VM
function VM_PowerOn($Server){

	$vCenter1="vCenter1.sub1.domain.com" 
	$vCenter2="vCenter2.sub2.domain.com"

	Write-Host "Attempting to power on $Server"
	#Check vCenter1
	try{
		write-host "Checking Seattle vCenter"
		Connect-VIServer $vCenter1
		Get-VM -Name $Server | Start-VM -Confirm:$false | Select Name,PowerState, VMHost
		Cleanup_SSH_Sessions
	}
	#Check vCenter2
	Catch [VimException]{
		write-host "Checking Ashburn vCenter"
		Connect-VIServer $vCenter2
		Get-VM -Name $Server | Start-VM -Confirm:$false | Select Name,PowerState, VMHost
		Cleanup_SSH_Sessions
	}
	Catch{
		Write-Host "Server not found on Seattle or Ashburn vSphere"
		write-host "Server maybe physcial"
	}
	

	Cleanup_SSH_Sessions
}
