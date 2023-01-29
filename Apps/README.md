# Instructions
## Testing
Testing the application deployment should generally be a must to ensure primarily:
* That the install actually does install silently in your environment
* All the required aspects and unrequired aspects are in place or removed respectively.

E.g. when installing Firefox you would genereally want no desktop shortcut and no autoupdate services running. 

To test a package usually involves running powershell under the SYSTEM context using PSEXEC and running the script / installer silent switches. 

### Azure VM
If test computer is an Azure VM, you can copy and paste the script into the Run Command > **Run Powershell Script** under the **Operations** menu 
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/run-command#azure-portal

### Non Azure VMs

On the test vanilla Windows PC:   

1. Download psexec from the sysinternals page https://download.sysinternals.com/files/PSTools.zip
2. Extract psexec.exe and place it in your C:\windows\system32 folder
3. Open and Administrative PS or cmd prompt and run `psexec -s -h powershell` this invokes powershell under the system context

	a. You can test by running the `whoami` command
4. You can now run the script or paste in the contents of the script or run the silent install commands directly 

