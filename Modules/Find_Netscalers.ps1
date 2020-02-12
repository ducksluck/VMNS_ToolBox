Import-Module Posh-SSH

function Find_Netscalers($Server, $creds, $Netscalers, $Check){

	$Bindings = New-Object "string[,]" 10,20
	$row = 0
	$column = 0

    Cleanup_SSH_Sessions | Out-Null
    
    Foreach($ns in $Netscalers){
		$column = 0
        try{$ssh = New-SSHSession -ComputerName $ns -Credential $creds}
		catch{Exit-PSSession}

		$response = $(Invoke-SSHCommand -SSHSession $ssh -Command "show server | grep -i $Server").Output
		

		if ($response -like "*Name:*"){
		
			#Node Name
            write-host "-----------------------------------------`n" -ForegroundColor Yellow
			write-host -NoNewline "Server found on: "
			write-host $ns -ForegroundColor Green
			
			$tempResp = $response -replace '(^\s+|\s+$)','' -replace '\s+',' '
			$temp = $tempResp.Split(" ")

			$nodeName= $temp[-2]
			write-host -NoNewline "`t`t   Node: "; write-host $nodeName -ForegroundColor Green
			
			
			if($Check -eq 0){
				#prompt user to cofirm correct Node
				write-host "`n"
				$isCorrect = (Read-Host -Prompt 'Is this the correct server? (y/n) ').ToLower()
				if(($isCorrect -eq "y") -or ($isCorrect -eq "yes")){
					$Bindings[$row,$column] = $ns

			
			    #Node State
			    $enabled = $temp[-1].Split(":")[1] 
			    write-host -NoNewline "  Node State: " 
			    if ($enabled -eq "ENABLED"){
				    write-host $enabled -ForegroundColor Green
			    }
			    Else{
				    write-host $enabled -ForegroundColor Red
			    }
		
			    $ipAddress_response = $(Invoke-SSHCommand -SSHSession $ssh -Command "show server $nodeName | grep IPAddress").Output
			    $serviceGroups = $(Invoke-SSHCommand -SSHSession $ssh -Command "show server $nodeName | grep ServiceGroup").Output #State UP/Down included in response
		
		
			    #Node IP
			    $ipAddress = $ipAddress_response.Split(" ")
			    Foreach($x in $ipAddress){
				    if ($x -like "*.*"){
					    write-host -NoNewline "`tIP: "
					    write-host $x -ForegroundColor Green
				    }
			    }
			
			    #Node Service Group Bindings
			    Foreach($x in $serviceGroups){
				    if ($x -like "*ServiceGroup*"){ 
					    $SG_Temp = $x -replace '(^\s+|\s+$)','' -replace '\s+',' '
					    $svcGroup = $SG_Temp.Split(" ")

					    #Service Group pool name:
					    write-host -NoNewline "`tMember of svc group: "
                        $column+=$column+1
					    if (($svcGroup[2]) -like "*SERVICE*"){
						    write-host -NoNewline "Out of Service"	-ForegroundColor Yellow
						    $column+=$column+1
                            $Bindings[$row,$column] = "Out of Service"
					    }
					    else{
						    write-host -NoNewline ($svcGroup[2])	-ForegroundColor Green
						    $Bindings[$row,$column] = ($svcGroup[2])
						
					    }
					
					    #State of node in service group:
					    write-host -NoNewline "   State: "
					    $state = $svcGroup[0].Split(":")[1] 
					    if ($state -eq "UP"){
						    write-host $state -ForegroundColor Green
					    }
					    ElseIf($state -eq "Down"){
						    write-host $state -ForegroundColor Red					
					    }
					    Else{
						    write-host $state -ForegroundColor Yellow
					    }
					    $column = $column + 1 
				    }
			    }		
			    #write-host "`n"
			    $row = $row+1 

				}
                #If doesn't enter 'y' or 'yes'
                else{write-host "User rejected result! Checking remaining netscalers..." }
			}
		}
        Cleanup_SSH_Sessions | Out-Null
    }
	#write-host "Bindings: ",$Bindings
    return $nodeName, $Bindings
}
