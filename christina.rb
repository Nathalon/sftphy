# Copyright (C) 2023, Nathalon

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# What is Net::SFTP?

# Net::SFTP is a pure-Ruby implementation of the SFTP protocol. 
# That’s “SFTP” as in “Secure File Transfer Protocol”, as defined as an adjuct to the SSH specification. 
# Not “SFTP” as in “Secure FTP” (a completely different beast). 
# Nor is it an implementation of the “Simple File Transfer Protocol” (which is in no way secure).

require 'net/sftp'
require 'ostruct'
require 'optparse'

class Christina

  Author = "Author => (Nathalon)"
  Script = "Script => (christina.rb)"
  Version = "Version => (0.0.1)"

  def run(arguments)
    parse(arguments)
    connect(arguments)
  end

  private

  def parse(arguments)
    ARGV << "-h" if ARGV.empty?
    @options = OpenStruct.new
    
    args = OptionParser.new do |args|
      args.banner = "Usage: #{__FILE__} [options]"
      
      args.on("-s", "--set-host=HOST", String,
         "The Host To Connect To") do |set_host|
         @options.set_host = set_host
      end
	  
      args.on("-u", "--username=USERNAME", String,
         "Authenticate With A Username") do |username|
         @options.username = username
      end

      args.on("-p", "--password=PASSWORD", String,
         "Authenticate With A Password") do |password|
         @options.password = password
      end

      args.on("-w", "--wharf=WHARF", Integer,
         "Specify The Wharf (Port) The Service Is Running") do |wharf|
         @options.wharf = wharf
      end

      args.on("-t", "--transfer=FILE", String,
         "Upload An Entire File On Disk") do |transfer|
         @options.transfer = transfer
      end

      args.on("-d", "--destination=FILE", String,
         "Destination For The Uploaded File") do |destination|
         @options.destination = destination
      end

      args.on("-m", "--mkdir=CREATE DIRECTORY", String,
         "Create A Directory") do |mkdir|
         @options.mkdir = mkdir
      end

      args.on("-r", "--rmdir=REMOVE DIRECTORY", String,
         "Remove A Directory") do |rmdir|
         @options.rmdir = rmdir
      end

      args.on("-q", "--query=FILE", String,
         "Query A File’s Permissions") do |query|
         @options.query = query
      end

      args.on("-e", "--erase=FILE", String,
         "Delete A File") do |erase|
         @options.erase = erase
      end

      args.on("-c", "--change=FILE", String,
         "Change A File’s Permissions") do |change|
         @options.change = change 
      end

      args.on("-a", "--authorization=INTEGER", Integer,
         "Combine With The Above Command To Change A File's Permissions") do |authorization|
         @options.authorization = authorization
      end

      args.on("-b", "--brand=FILE", String,
         "Brand (Rename) A File") do |name|
         @options.name = name
      end

      args.on("-n", "--new=FILE", String,
         "The Name Off The Renamed File") do |new|
         @options.new = new
      end

      args.on("-l", "--list=DIRECTORY", String,
         "Query The Contents Of A Directory") do |list|
         @options.list = list
      end

      args.on("-g", "--grab=FILE", String,
         "Grab Data Off The Remote Host Directly To A Buffer") do |grab|
         @options.grab = grab
      end

      args.on("-f", "--file=FILE", String,
         "Download Directly To A Local File") do |file|
         @options.file = file
      end

      args.on("-o", "--output=FILE", String,
         "Destination Off The Downloaded File") do |output|
         @options.output = output
      end

      args.on("-h", "--help", "Show Help And Exit") do
        puts args
        exit
      end

      args.on("-V", "--version", "Show Version And Exit") do
        puts Author
        puts Script
        puts Version
        exit      
      end

      begin
        args.parse!(arguments)
      
      rescue OptionParser::MissingArgument => error
        puts "[!] => #{error.message}"
        exit

      rescue OptionParser::InvalidOption => error
        puts "[!] => #{error.message}"
        exit
      end
    end
  end

  def connect(arguments)
    output("----------------------------------------------------------")
    output("[*] Starting at => #{Time.now}")
    output("[*] Operating System => #{RUBY_PLATFORM}")
    output("----------------------------------------------------------")

    output("[i] Connecting to Secure SHell")
    output("\t-- Host => #{@options.set_host}")
    output("\t-- Username => #{@options.username}")
    output("\t-- Password => #{@options.password}")
    output("\t-- Wharf => #{@options.wharf}")
    output("----------------------------------------------------------")

    Net::SFTP.start(@options.set_host, @options.username, :password => @options.password, :port => @options.wharf) do |sftp|
      mkdir(sftp) if @options.mkdir
      rmdir(sftp) if @options.rmdir
      remove(sftp) if @options.erase         
      query(sftp) if @options.query
      list(sftp) if @options.list
      grab(sftp) if @options.grab
      rename(sftp) if @options.name || @options.new
      change(sftp) if @options.change || @options.authorization
      upload(sftp) if @options.transfer || @options.destination
      download(sftp) if @options.file || @options.output
    end

    output("----------------------------------------------------------")
    output("[*] Exiting at => #{Time.now}")
    output("----------------------------------------------------------")
  end

  def mkdir(sftp)
    sftp.mkdir!(@options.mkdir)
    output("[i] Creating Directory => #{@options.mkdir}")
  end

  def rmdir(sftp)
    sftp.rmdir!(@options.rmdir)     
    output("[i] Removing Directory => #{@options.rmdir}")
  end

  def remove(sftp)
    sftp.remove!(@options.erase)
    output("[i] Removing File => #{@options.erase}")
  end

  def query(sftp)
    output("[i] Checking Permissions => #{sftp.stat!(@options.query).permissions}")
  end

  def grab(sftp)
    sftp.download!(@options.grab)
    output("[i] Grabing File => #{@options.grab}")
  end

  def rename(sftp)
    sftp.rename!(@options.name, @options.new)
    output("[i] Renaming File => #{@options.name}")
    output("[i] New File => #{@options.new}")
  end

  def change(sftp)
    sftp.setstat!(@options.change, :permissions => @options.authorization)
    output("[i] Setting Permissions To => #{@options.change}")
    output("[i] Permissions Set To => #{@options.authorization}")
  end

  def upload(sftp)  
    sftp.upload!(@options.transfer, @options.destination)
    output("[i] Uploading File To => #{@options.set_host}")
    output("\t-- Local File => #{@options.transfer}")
    output("\t-- File Destination => #{@options.destination}")
  end

  def download(sftp)
    sftp.download!(@options.file, @options.output)
    output("[i] Downloading File From => #{@options.set_host}")
    output("\t-- Remote File => #{@options.file}")
    output("\t-- File Destination => #{@options.output}")
  end

  def list(sftp)
    output("[i] Listing Contents Of => #{@options.list}")
    output("----------------------------------------------------------")
    sftp.dir.foreach(@options.list) do |entry|
    output(entry.longname)
  end
end

  def output(string)
    puts "#{string}"
  end
end

sftp = Christina.new
sftp.run(ARGV)
