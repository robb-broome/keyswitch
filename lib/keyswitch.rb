#!/usr/bin/env ruby
require 'pp'
require 'optparse'
require 'ostruct'
require 'fileutils'
require 'pry'

class Keyswitch

  BASE_DIR = File.join(Dir.home,'.ssh')
  AVAILABLE_LOCALES = Dir.glob(File.join(BASE_DIR,'*')).map {|f| File.directory?(f) ? f.split('/').last : nil}.compact

  def self.parse args
    options = OpenStruct.new
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on('-i', '--id KEYBASE', AVAILABLE_LOCALES, 'Name of KEYBASE to switch to') do |id|
        options.locale = id
        puts "Switching keys to #{id}"
        # copy that keybase over
        backup_folder = File.join(BASE_DIR, 'hold', '/')
        FileUtils.rm_r backup_folder
        Dir.mkdir backup_folder

        active_files = Dir.glob(File.join(BASE_DIR,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
        source_folder = File.join(BASE_DIR, id, '/')
        source_files = Dir.glob(File.join(source_folder,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
        if options.verbose
        puts 'SOURCE'
        source_files.each {|f| puts f}
        puts 'SOURCE'
        end


        active_files.each do |file|
          puts "Backing up #{file}" if options.verbose
          FileUtils.cp file, backup_folder
        end

        active = active_files.map{|file| file.split('/').last}

        backed_up_files = Dir.glob(File.join(backup_folder,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
        backed_up = backed_up_files.map{|file| file.split('/').last}

        unless (active == backed_up)
          if options.verbose
            puts 'backup failure stats'
            puts 'active---------------'
            puts active
            puts 'backed up ---------------'
            puts backed_up
            puts 'difference 1'
            puts active - backed_up
            puts 'difference 2'
            puts backed_up - active
          end
          raise 'Backup failure'
        end

        puts "back up success"
        active_files.each do |file|
          puts "Removing #{file}" if options.verbose
          FileUtils.rm file
        end

        source_files.each do |file|
          puts "Copying #{file}" if options.verbose
          FileUtils.cp file, BASE_DIR
        end
        puts "Switched to #{id}"
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end

Keyswitch.parse ARGV
