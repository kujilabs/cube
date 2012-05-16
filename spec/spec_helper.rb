$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'cube'
require 'webmock'
require 'vcr'

begin
  require 'ruby-debug'
rescue 
  puts "debugger not found!"
end


# def configure_mondrian
#   XMLA.configure do |c|
#     c.endpoint = "http://localhost:8080/mondrian/xmla"
#     c.catalog = "Husky"
#   end
# end


def configure_icube
  XMLA.configure do |c|
    c.endpoint = "http://localhost:8282/icCube/xmla"
    c.catalog = "GOSJAR"
  end
end

def configure_mondrian
  XMLA.configure do |c|
    c.endpoint = "http://localhost:8383/mondrian/xmla"
    c.catalog = "GOSJAR"
  end
end


VCR.config do |c|
  c.default_cassette_options = { :record => :none } 
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
end


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true 
end
