require 'coveralls'
Coveralls.wear!

module YAYEncSpecHelper
  FILES_DIR = Pathname.new(File.expand_path('../files', __FILE__)).freeze

  def file_path(file_name)
    (FILES_DIR + file_name).to_s
  end
end
