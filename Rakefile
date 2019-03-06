ENV['MRUBY_CONFIG']  ||= File.expand_path('build_config.rb')
ENV['MRUBY_VERSION'] ||= 'stable'

file :mruby do
  case ENV['MRUBY_VERSION'].downcase
  when 'head'
    sh 'git clone --depth 1 git://github.com/mruby/mruby.git'
  when 'stable'
    sh 'git clone --depth 1 git://github.com/mruby/mruby.git -b stable'
  else
    sh "curl -L --fail --retry 3 --retry-delay 1 https://github.com/mruby/mruby/archive/#{ENV['MRUBY_VERSION']}.tar.gz -s -o - | tar zxf -" # rubocop:disable LineLength
    mv "mruby-#{ENV['MRUBY_VERSION']}", 'mruby'
  end
end

Rake::Task[:mruby].invoke

namespace :mruby do
  Dir.chdir('mruby') { load 'Rakefile' }
end

desc 'compile binary'
task compile: 'mruby:all'

desc 'test'
task test: 'mruby:test'

desc 'cleanup'
task clean: 'mruby:clean'

desc 'cleanup all'
task cleanall: 'mruby:deep_clean'
