## sftphy

**What is Net::SFTP?**  

**Net::SFTP is a pure-Ruby implementation of the SFTP protocol.**  
**That’s “SFTP” as in “Secure File Transfer Protocol”, as defined as an adjuct to the SSH specification.**  
**Not “SFTP” as in “Secure FTP” (a completely different beast).**  
**Nor is it an implementation of the “Simple File Transfer Protocol” (which is in no way secure).**

## Dependencies

**ruby: `$ sudo apt install ruby -y`**  
**net-sftp: `$ sudo gem install net-sftp`**  

**The commands are pretty straight forward.**  
**Let's go through them one by one.**  

**`$ ruby sftphy.rb -u /local/path/to/file -r /remote/path -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb -d /remote/path/to/file -r /local/path -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --mkdir /remote/path/to/directory -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --rmdir /remote/path/to/directory -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --rmfile /remote/path/to/file -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --queryperm /remote/path/to/file_or_directory -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --chmod PERMISSIONS -r /remote/path/to/file_or_directory -h HOST -U USERNAME -p PASSWORD`**  
**`$ ruby sftphy.rb --list /remote/path -h HOST -U USERNAME -p PASSWORD`**  

![Ruby](https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white/)
