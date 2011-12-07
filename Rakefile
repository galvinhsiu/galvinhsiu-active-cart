require 'rake/testtask'

desc 'Run all tests'
task :test do
  ENV['RAILS_ENV'] = 'test'
  $LOAD_PATH.unshift(File.expand_path('test'))
  require 'test/unit'
  Dir['test/**/test_*.rb'].each {|test| require "./#{test}" }
end

desc 'Generate YARD Documentation'
task :doc do
  sh "mv README TEMPME"
  sh "rm -rf doc"
  sh "yardoc"
  sh "mv TEMPME README"
end

namespace :gem do

  desc 'Build and install the active_cart gem'
  task :install do
    sh "gem build galvinhsiu-active_cart.gemspec"
    sh "sudo gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end

  desc 'Uninstall the active_cart gem'
  task :uninstall do
    sh "sudo gem uninstall -x galvinhsiu-active_cart"
  end

end

task :default => :test
