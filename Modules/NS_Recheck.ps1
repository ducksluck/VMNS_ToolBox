function NS_Recheck($nodeName, $Bound_Scalers, $My_Creds){     
    #Recheck node to confirm state (up/down)
    write-host "`n`nCurrent State:" -Foreground Cyan

    for($x=0; $x -le $Bound_Scalers.GetUpperBound(0); $x++){
        if ($Bound_Scalers[$x,0].length -ne 0){
            Find_Netscalers $nodeName $My_Creds $Bound_Scalers[$x,0] 1 | Out-Null
        }
    }
}