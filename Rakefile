$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'rake/testtask'

require 'yayenc/version'

task :default => [:test]

task :test do
  Rake::TestTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/test_*.rb']
    t.verbose = false
  end
end

task :build do
  system 'gem build yayenc.gemspec'
end

task :release => :build do
  system "gem push yayenc-#{YAYEnc::VERSION}.gem"
end

task :clean do
  system 'rm -f *.gem'
end
