source "http://rubygems.org"

gemspec

group :development, :test do
  gem "ruby-debug", :platforms => :mri_18
  #for 1.9.3 
  #bash < <(curl -L https://raw.github.com/gist/1333785)
  gem 'linecache19',       '>= 0.5.13', :platforms => :mri_19
  gem 'ruby-debug-base19', '>= 0.11.26', :platforms => :mri_19
  gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :mri_19
  gem "vcr"
  gem "rspec", "~> 2.8.0"
  gem "bundler", ">= 1.0.0"
end
