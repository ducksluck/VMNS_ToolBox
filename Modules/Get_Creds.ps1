function Get_Creds(){
    #
    
    if($env:USERNAME[1] -eq '-'){
        $temp = $env:USERNAME.Replace("s-","")
        $Creds = Get-Credential "domain\$temp"
        
        #write-host "corrected username: $Creds"
        return $Creds
        }
    ElseIf($env:USERNAME[1] -ne '-'){
        $temp = Get-Credential "domain\$env:USERNAME"
        #write-host "user name: $temp"
        $Creds = $temp
        return $Creds
    }
    
}