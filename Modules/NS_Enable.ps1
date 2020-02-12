
function NS_Enable($nodeName, $creds, $Bound_Scalers){

	for($x=0; $x -le $Bound_Scalers.GetUpperBound(0); $x++){
	
		#Enable node
		if ($Bound_Scalers[$x,0].length -ne 0){
			New-SSHSession -ComputerName $Bound_Scalers[$x,0] -Credential $creds | Out-Null
			write-host "Enabling on: ", $Bound_Scalers[$x,0]
			Invoke-SSHCommand -Index 0 -Command "enable server $nodeName"  | Out-Null
		}
	}
}
