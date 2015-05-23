Gem::Specification.new do |s|
  s.name	= 'ruby-yayenc'
  s.version 	= '0.0.1'
  s.date	= '2015-05-22'
  s.summary	= 'YAYEnc is a 100% Ruby yEnc encoding/decoding solution.'
  s.authors	= ["Chris Lucas"]
  s.email	= '' 
  s.files	= %w(LICENSE README.markdown Rakefile CHANGELOG.markdown ruby-yayenc.gemspec)
  s.files	+=  Dir.glob("lib/**/*.rb")
  s.files	+=  Dir.glob("test/**/*")
  s.homepage	= 'https://github.com/cjlucas/ruby-yayenc'
  s.license	= 'MIT'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rake'
end
