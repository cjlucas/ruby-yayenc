require 'simplecov'
require 'coveralls'

class SimpleFormatter
  def format(result)
    puts "Coverage: #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
end

require 'test/unit'
require 'pathname'

require 'yayenc'

module YAYEncSpecHelper
  FILES_DIR = Pathname.new(File.expand_path('../files', __FILE__)).freeze

  def file_path(file_name)
    (FILES_DIR + file_name).to_s
  end
end
