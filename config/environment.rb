$stdout.sync = true
require 'pry'
require 'settingslogic'
require File.expand_path('../../lib/keyswitch', __FILE__)

KSW_ENV = ENV['RACK_ENV'] || 'development'
# DB = Sequel.connect(YAML.load_file(File.expand_path('../../config/store.yml', __FILE__))[RTX_ENV])

Log = Logger.new(STDOUT)
Log.level = Logger::DEBUG

Dir[File.expand_path(File.join('../../config/**/*.rb'), __FILE__)].each {|file| require file }
Dir[File.expand_path(File.join('../../lib/**/*.rb'), __FILE__)].each {|file| require file }
