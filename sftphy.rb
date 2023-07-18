#!/usr/bin/env ruby

# Copyright 2023 Elijah Gordon (SLcK) <braindisassemblue@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'net/sftp'
require 'ostruct'
require 'optparse'

class Sftphy
  AUTHOR = "Author => (SLcK)"
  SCRIPT = "Script => (sftphy.rb)"
  VERSION = "Version => (1.0.0)"

  def run(arguments)
    parse(arguments)
    connect
  end

  private

  def parse(arguments)
    ARGV << "-h" if ARGV.empty?
    @options = OpenStruct.new

    OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.on("-s", "--set-host=HOST", String, 
      	      "The Host To Connect To") do |set_host|
        @options.set_host = set_host
      end

      opts.on("-u", "--username=USERNAME", String, 
              "Authenticate With A Username") do |username|
        @options.username = username
      end

      opts.on("-p", "--password=PASSWORD", String, 
              "Authenticate With A Password") do |password|
        @options.password = password
      end

      opts.on("-w", "--wharf=WHARF", Integer, 
              "Specify The Wharf (Port) The Service Is Running") do |wharf|
        @options.wharf = wharf
      end

      opts.on("-t", "--transfer=FILE", String, 
              "Upload An Entire File On Disk") do |transfer|
        @options.transfer = transfer
      end

      opts.on("-d", "--destination=FILE", String, 
              "Destination For The Uploaded File") do |destination|
        @options.destination = destination
      end

      opts.on("-m", "--mkdir=CREATE DIRECTORY", String, 
              "Create A Directory") do |mkdir|
        @options.mkdir = mkdir
      end

      opts.on("-r", "--rmdir=REMOVE DIRECTORY", String, 
              "Remove A Directory") do |rmdir|
        @options.rmdir = rmdir
      end

      opts.on("-q", "--query=FILE", String, 
              "Query A File’s Permissions") do |query|
        @options.query = query
      end

      opts.on("-e", "--erase=FILE", String, 
              "Delete A File") do |erase|
        @options.erase = erase
      end

      opts.on("-c", "--change=FILE", String, 
              "Change A File’s Permissions") do |change|
        @options.change = change
      end

      opts.on("-a", "--authorization=INTEGER", Integer, 
              "Combine With The Above Command To Change A File's Permissions") do |authorization|
        @options.authorization = authorization
      end

      opts.on("-b", "--brand=FILE", String, 
              "Brand (Rename) A File") do |name|
        @options.name = name
      end

      opts.on("-n", "--new=FILE", String, 
              "The Name Of The Renamed File") do |new|
        @options.new = new
      end

      opts.on("-l", "--list=DIRECTORY", String, 
              "Query The Contents Of A Directory") do |list|
        @options.list = list
      end

      opts.on("-f", "--file=FILE", String, 
              "Download Directly To A Local File") do |file|
        @options.file = file
      end

      opts.on("-o", "--output=FILE", String,
              "Destination Of The Downloaded File") do |output|
        @options.output = output
      end

      opts.on("-h", "--help", 
              "Show Help And Exit") do
        puts opts
        exit
      end

      opts.on("-V", "--version", 
              "Show Version And Exit") do
              
        puts AUTHOR
        puts SCRIPT
        puts VERSION
        exit
      end

      begin
        opts.parse!(arguments)
      rescue OptionParser::MissingArgument, OptionParser::InvalidOption => error
        handle_error(error)
      end
    end
  end

  def connect
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

    begin
      Net::SFTP.start(@options.set_host, @options.username, password: @options.password, port: @options.wharf) do |sftp|
        mkdir(sftp) if @options.mkdir
        rmdir(sftp) if @options.rmdir
        remove(sftp) if @options.erase
        query(sftp) if @options.query
        list(sftp) if @options.list
        rename(sftp) if @options.name || @options.new
        change(sftp) if @options.change || @options.authorization
        upload(sftp) if @options.transfer || @options.destination
        download(sftp) if @options.file || @options.output
      end
    rescue Net::SFTP::StatusException => error
      handle_error(error)
    end

    output("----------------------------------------------------------")
    output("[*] Exiting at => #{Time.now}")
    output("----------------------------------------------------------")
  end

  def mkdir(sftp)
    sftp.mkdir!(@options.mkdir)
    output("[i] Creating Directory => #{@options.mkdir}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def rmdir(sftp)
    sftp.rmdir!(@options.rmdir)
    output("[i] Removing Directory => #{@options.rmdir}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def remove(sftp)
    sftp.remove!(@options.erase)
    output("[i] Removing File => #{@options.erase}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def query(sftp)
    output("[i] Checking Permissions => #{sftp.stat!(@options.query).permissions}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def rename(sftp)
    sftp.rename!(@options.name, @options.new)
    output("[i] Renaming File => #{@options.name}")
    output("[i] New File => #{@options.new}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def change(sftp)
    sftp.setstat!(@options.change, permissions: @options.authorization)
    output("[i] Setting Permissions To => #{@options.change}")
    output("[i] Permissions Set To => #{@options.authorization}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def upload(sftp)
    sftp.upload!(@options.transfer, @options.destination)
    output("[i] Uploading File To => #{@options.set_host}")
    output("\t-- Local File => #{@options.transfer}")
    output("\t-- File Destination => #{@options.destination}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def download(sftp)
    sftp.download!(@options.file, @options.output)
    output("[i] Downloading File From => #{@options.set_host}")
    output("\t-- Remote File => #{@options.file}")
    output("\t-- File Destination => #{@options.output}")
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def list(sftp)
    output("[i] Listing Contents Of => #{@options.list}")
    output("----------------------------------------------------------")
    sftp.dir.foreach(@options.list) do |entry|
      output(entry.longname)
    end
  rescue Net::SFTP::StatusException => error
    handle_error(error)
  end

  def handle_error(error)
    puts "[!] => #{error.message}"
    exit
  end

  def output(string)
    puts string
  end
end

sftp = Sftphy.new
sftp.run(ARGV)
