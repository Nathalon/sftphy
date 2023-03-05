require 'net/sftp'
require 'ostruct'
require 'optparse'

class Sftphy

  Author = "Author => (Nathalon)"
  Script = "Script => (sftphy.rb)"
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
         "The Name Of The Renamed File") do |new|
         @options.new = new
      end

      args.on("-l", "--list=DIRECTORY", String,
         "Query The Contents Of A Directory") do |list|
         @options.list = list
      end

      args.on("-g", "--grab=FILE", String,
         "Grab Data Of The Remote Host Directly To A Buffer") do |grab|
         @options.grab = grab
      end

      args.on("-f", "--file=FILE", String,
         "Download Directly To A Local File") do |file|
         @options.file = file
      end

      args.on("-o", "--output=FILE", String,
         "Destination Of The Downloaded File") do |output|
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
    begin 
      sftp.mkdir!(@options.mkdir)
      output("[i] Creating Directory => #{@options.mkdir}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def rmdir(sftp)
    begin
      sftp.rmdir!(@options.rmdir)     
      output("[i] Removing Directory => #{@options.rmdir}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def remove(sftp)
    begin
      sftp.remove!(@options.erase)
      output("[i] Removing File => #{@options.erase}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def query(sftp)
    begin
      output("[i] Checking Permissions => #{sftp.stat!(@options.query).permissions}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def grab(sftp)
    begin
      sftp.download!(@options.grab)
      output("[i] Grabing File => #{@options.grab}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def rename(sftp)
    begin
      sftp.rename!(@options.name, @options.new)
      output("[i] Renaming File => #{@options.name}")
      output("[i] New File => #{@options.new}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def change(sftp)
    begin
      sftp.setstat!(@options.change, :permissions => @options.authorization)
      output("[i] Setting Permissions To => #{@options.change}")
      output("[i] Permissions Set To => #{@options.authorization}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def upload(sftp) 
    begin  
      sftp.upload!(@options.transfer, @options.destination)
      output("[i] Uploading File To => #{@options.set_host}")
      output("\t-- Local File => #{@options.transfer}")
      output("\t-- File Destination => #{@options.destination}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
  end

  def download(sftp)
    begin
      sftp.download!(@options.file, @options.output)
      output("[i] Downloading File From => #{@options.set_host}")
      output("\t-- Remote File => #{@options.file}")
      output("\t-- File Destination => #{@options.output}")

    rescue Net::SFTP::StatusException => error
      output("[!] => #{error.message}")

    ensure
      output("----------------------------------------------------------")
      output("[*] Exiting")
      output("----------------------------------------------------------")
      exit
    end
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

sftp = Sftphy.new
sftp.run(ARGV)
