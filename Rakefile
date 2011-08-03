begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

#
# Note: 
#   instant_coffee.rake is relative to the instant-coffee project root. 
#   Be sure to place this where you need it.
#
load "lib/tasks/instant_coffee.rake"


desc "Start instant_coffee, and jasmine all at once."
task "develop" do
  ts = []
  ts.push(Thread.new do
    Rake::Task["instant_coffee:watch"].invoke
  end)
  ts.push(Thread.new do
    Rake::Task["jasmine"].invoke
  end)

  ts.each{|t|t.join}
end
