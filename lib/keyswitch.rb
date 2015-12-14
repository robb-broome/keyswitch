#!/usr/bin/env ruby
require 'pp'
require 'optparse'
require 'ostruct'
require 'fileutils'
require 'pry'
require 'logger'

class BackupFailure < StandardError
end

class Keybase

  BASE_DIR = File.join(Dir.home,'.ssh')
  AVAILABLE_COMPANIES = Dir.glob(File.join(BASE_DIR,'*')).map {|f| File.directory?(f) ? f.split('/').last : nil}.compact

  attr_accessor :logger

  def initialize
    @logger = Logger.new STDOUT
    @logger.level = Logger::WARN
    @logger.info  'SOURCE FILES'
  end

  def make_active company
    backup_active_files
    remove_active
    move_id_to_active company
  end

  def move_id_to_active company
    source_folder = File.join(BASE_DIR, company, '/')
    source_files = Dir.glob(File.join(source_folder,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
    logger.info  'SOURCE FILES'
    source_files.each {|f| logger.info f}

    source_files.each do |file|
      logger.info "Copying #{file}"
      FileUtils.cp file, BASE_DIR
    end

    logger.warn "Switched to #{company}"
  end

  def active_files
    Dir.glob(File.join(BASE_DIR,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
  end

  def backup_active_files
    active_files.each do |file|
      logger.info "Backing up #{file}"
      FileUtils.cp file, backup_folder
    end
  end

  def remove_active
    verify_backup
    active_files.each do |file|
      logger.info "Removing #{file}"
      FileUtils.rm file
    end
  end

  def backup_folder
    backup_folder = File.join(BASE_DIR, 'hold', '/')
  end

  def insure_backup_folder
    FileUtils.rm_r backup_folder
    Dir.mkdir backup_folder
  end

  def backed_up_files
    Dir.glob(File.join(backup_folder,'*')).map {|f| File.directory?(f) ? nil : f.to_s}.compact.sort
  end

  def backed_up_file_names
    backed_up_files.map{|file| file.split('/').last}
  end

  def active_file_names
    active_files.map{|file| file.split('/').last}
  end

  def active_is_backed_up?
    active_files_not_backed_up.empty?
  end

  def active_files_not_backed_up
    active_file_names - backed_up_file_names
  end

  def verify_backup
    raise BackupFailure, "Backup failed to backup #{active_files_not_backed_up}" unless active_is_backed_up?
  end
end

class Keyswitch


  def self.parse args
    options = OpenStruct.new
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      keybase = Keybase.new
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on('-i', '--id KEYBASE', Keybase::AVAILABLE_COMPANIES, 'Name of KEYBASE to switch to') do |id|
        options.company = id
        keybase.make_active id
        puts "#{id} keys are now active"
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        # TODO: Set logger level in Keybase
        # keybase.logger.level Logger::INFO
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
