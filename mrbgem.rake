MRuby::Gem::Specification.new('mruby-body-parser') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Tomas Pollak'
  spec.summary = 'Mruby Body Parser'

  spec.add_dependency 'mruby-json', mgem: 'mruby-json'
  # spec.add_dependency 'mruby-env', mgem: 'mruby-env'
  spec.add_dependency 'mruby-onig-regexp', mgem: 'mruby-onig-regexp'

  spec.add_test_dependency 'mruby-input-stream', github: 'takahashim/mruby-input-stream'
  spec.add_test_dependency 'mruby-sprintf', core: 'mruby-sprintf'
  spec.add_test_dependency 'mruby-print',   core: 'mruby-print'
  spec.add_test_dependency 'mruby-time',    core: 'mruby-time'
  spec.add_test_dependency 'mruby-io',      core: 'mruby-io'
end
