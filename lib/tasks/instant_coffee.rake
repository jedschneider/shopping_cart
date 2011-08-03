
INSTANT_COFFEE_URL = "http://cloud.github.com/downloads/fredericksgary/instant-coffee/instant-coffee-0.0.1-standalone.jar"
INSTANT_COFFEE_JAR = INSTANT_COFFEE_URL[/\/([^\/]+)$/, 1]

require 'digest/sha1'
require 'net/http'
require 'fileutils'

begin
  require 'rubygems'
  require 'libnotify'
rescue Exception
  nil
end
begin
  require 'ftools'
rescue Exception
  nil
end

module InstantCoffeeRakeHelper
  # Retrieves uri over https and saves to filename
  def self.http_get(uri, filename)
    uri = URI.parse(uri)
    res = Net::HTTP.start(uri.host, uri.port){|http|
      http.get uri.path
    }
    open(filename,'w'){|f|f.write(res.body)}
  end
end

namespace :instant_coffee do

  desc "Ensure existence of tmp directories"
  task :prepare_tmp do
    `mkdir -p tmp`
  end

  desc "Ensure presence of jcoffeescript jar"
  task :ensure_jar => :prepare_tmp do
    Dir.chdir 'tmp' do
      if(Dir.glob('instant-coffee*').empty?)
        InstantCoffeeRakeHelper.http_get(INSTANT_COFFEE_URL, INSTANT_COFFEE_JAR)
      end
    end
  end

  desc "Build all src files"
  task :build => :ensure_jar do
    system "java -jar tmp/#{INSTANT_COFFEE_JAR}"
  end

  desc "Build all src files and watch for changes"
  task :watch => :ensure_jar do
    system "java -jar tmp/#{INSTANT_COFFEE_JAR} watch"
  end
end
