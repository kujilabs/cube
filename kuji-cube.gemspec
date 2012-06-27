# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "cube/version"

Gem::Specification.new do |gem|
  gem.authors       = ["drKreso", "stellard"]
  gem.email         = ["kresimir.bojcic@gmail.com", "scott@kujilabs.com"]
  gem.description = "Eases the pain I had to go through to get to the data out of XMLA based OLAP provider(Mondiran, Pentaho, icCube)"
  gem.summary = "Get's the data from OLAP cube via XMLA(Mondiran, Pentaho, icCube)"
  gem.homepage = "http://github.com/kujilabs/cube"
  gem.date = "2012-05-16"


  gem.licenses = ["MIT"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kuji-cube"
  gem.require_paths = ["lib"]
  gem.version = Cube::VERSION


  gem.add_dependency "savon", "0.9.7"
  gem.add_dependency "httpi", "0.9.5"
  gem.add_dependency "wasabi", "2.0.0"


# Using addressable (2.2.6) 
# Using builder (3.0.0) 
# Using gyoku (0.4.4) 
# Using akami (1.0.0) 
# Using archive-tar-minitar (0.5.2) 
# Using bundler (1.1.3) 
# Using columnize (0.3.6) 
# Using crack (0.3.1) 
# Using diff-lcs (1.1.3) 
# Using rack (1.4.1) 
# Using httpi (0.9.5) 
# Using nokogiri (1.5.0) 
# Using nori (1.0.2) 
# Using wasabi (2.0.0) 
# Using savon (0.9.7) 
# Using kuji-cube (1.5.2) from source at . 
# Using ruby_core_source (0.1.5) 
# Using linecache19 (0.5.13) 
# Using rspec-core (2.8.0) 
# Using rspec-expectations (2.8.0) 
# Using rspec-mocks (2.8.0) 
# Using rspec (2.8.0) 
# Using ruby-debug-base19 (0.11.26) 
# Using ruby-debug19 (0.11.6) 
# Using vcr (1.11.3) 
# Using webmock (1.7.10) 

end

