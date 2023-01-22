# Instructions
## Testing
Testing the application deployment should generally be a must to ensure primarily:
* That the install actually does install silently in your environment
* All the required aspects and unrequired aspects are in place or removed respectively.

E.g. when installing Firefox you would genereally want no desktop shortcut and no autoupdate services running. 

To test a package usually involves running powershell under the SYSTEM context PSEXEC , 
Download psexec from the sysinternals page https://download.sysinternals.com/files/PSTools.zip 

