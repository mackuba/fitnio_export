Gem::Specification.new do |s|
  s.name = "fitnio_export"
  s.version = "1.0"
  s.summary = "A tool for exporting activity data from Fitnio in GPX format (for importing into Runkeeper)"
  s.homepage = "http://github.com/psionides/fitnio_export"

  s.author = "Jakub Suder"
  s.email = "jakub.suder@gmail.com"

  s.files = ['MIT-LICENSE', 'README.markdown', 'lib/fitnio_export.rb']
  s.executables = ['fitnio_export']

  s.add_dependency 'mechanize', '~> 2.4'
  s.add_dependency 'highline', '>= 1.6.11'
  s.add_dependency 'json', '~> 1.7'
end
