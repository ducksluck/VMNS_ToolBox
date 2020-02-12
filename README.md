# VMNS_ToolBox
A quick way to search across VMware vCenters and Netscalers to perform a variety of tasks and gather information.

 **Use:** 
Provide the server name you wish to Disable/Enable in the netscaler, or Restart/Shutdown/Power on.  
Simply passing the server only name will return several bits of information on the server  

**Supported Arguements:**  
  -d(isable)              <- disables server in Netscaler   
  -e(nable)               <- enables  server in Netscaler   
  -r(estart) OR -reboot   <- disable, reboot VM, (wait 15 secs)then enable  
  -s(hutdown) OR -off     <- disable, shutdown VM  
  -on                     <- power on VM, enable in Netscaler  
  
**Example (disable in netscaler):**   
     Server> UnderwaterBasketWeavingWeb01 -d  

**Requirements:**  
  1) Install powerCLI (VMware-PowerCLI-6.5.0.exe bundled with this script) Check for more recent ver online  
  2) Get-Module -Name VMware* -ListAvailable | Import-Module  
  3) Install-Module -Name Posh-SSH  
  4) Restart powershell ISE  
  5) During first run you must accept the Netscaler fingerprints when prompted  

  **Note: If this is the first time using powershell run the following:**  
         Set-ExecutionPolicy Unrestricted  
         set-item WSMan:\localhost\Client\TrustedHosts *  

