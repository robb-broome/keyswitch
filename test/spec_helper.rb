require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require File.expand_path('../../config/environment', __FILE__)

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(reporter_options)]

