function Cleanup_SSH_Sessions(){
    #clean up old sessions:
    $oldSessions = Get-SSHSession | ForEach-Object {$_.SessionID}
    #$oldSessions = Get-SSHSession | select -expand SessionID
    Foreach ($i in $oldSessions){
        #write-host "Closing Session:  ",$i
        Remove-SSHSession $i |Out-Null
    }
}