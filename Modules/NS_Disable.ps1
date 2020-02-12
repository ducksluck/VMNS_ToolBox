
function NS_Disable($nodeName, $creds, $Bound_Scalers){

	for($x=0; $x -le $Bound_Scalers.GetUpperBound(0); $x++){
	
		#Disable node
		if ($Bound_Scalers[$x,0].length -ne 0){
			New-SSHSession -ComputerName $Bound_Scalers[$x,0] -Credential $creds | Out-Null
			write-host "Disabling on: ", $Bound_Scalers[$x,0]
			Invoke-SSHCommand -Index 0 -Command "disable server $nodeName"  | Out-Null
		}
	}

}