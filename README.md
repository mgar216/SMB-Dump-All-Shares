**Requirements: smbclient smbmap** -- both included with Kali

Created for the OSCP, this dumps all SMBShares on the target. Usage is simple...

Make sure you **chmod +x sdas.sh**

run it as root with with **sudo ./sdas.sh target [username] [password] [timeout-seconds]**

This will create a directory called **smb_dump** and within that it will create **separate folders** with the share name and everything dumped from it within.

If you get any timeouts while attempting to retrieve files, increase the seconds for timeout to >30 (default: 15s).
