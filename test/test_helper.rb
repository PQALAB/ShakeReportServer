ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "mocha/setup"
require 'webmock/test_unit'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
