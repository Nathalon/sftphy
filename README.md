## sftphy

**What is Net::SFTP?**  

**Net::SFTP is a pure-Ruby implementation of the SFTP protocol.**  
**That’s “SFTP” as in “Secure File Transfer Protocol”, as defined as an adjuct to the SSH specification.**  
**Not “SFTP” as in “Secure FTP” (a completely different beast).**  
**Nor is it an implementation of the “Simple File Transfer Protocol” (which is in no way secure).**

## Dependencies

**ruby: `$ sudo apt install ruby -y`**  
**net-sftp: `$ sudo gem install net-sftp`**  

**The Commands are pretty straight forward.**  
**Let's go through them one by one.**  

**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -t COPYING -d /tmp/COPYING`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -m directory /tmp/make`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -r directory /tmp/remove`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -q /tmp/query`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -e /tmp/erase`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -c /tmp/permissions -a 0644`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -b /tmp/named -n /tmp/renamed`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -l /tmp/listdirectory/`**  
**`$ ./sftphy.rb -s 192.168.1.109 -u username -p password -w 22 -f /tmp/download -o download`**  

![Ruby](https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white/)
