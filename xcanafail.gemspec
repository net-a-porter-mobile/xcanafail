Gem::Specification.new do |s|
  s.name        = 'xcanafail'
  s.version     = '0.0.4'
  s.date        = '2015-11-12'
  s.summary     = 'Pipe in the output of `xctool analyze` and it will fail on warnings.'
  s.description = 'Pipe in the output of `xctool analyze` and it will fail on warnings. This is designed as a temporary workaround for the --fail-on-warnings flag not failing on warnings :) When that bug is fixed, this gem should go away immediately.'
  s.authors     = ['Sam Dean']
  s.email       = 'sam.dean@net-a-porter.com'
  s.files       = ['lib/xcanafail.rb']
  s.executables << 'xcanafail'
  s.homepage    = 'http://rubygems.org/gems/xcanafail'
  s.license     = 'APACHE'
end
