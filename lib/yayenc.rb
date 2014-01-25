require 'yayenc/compat'
require 'yayenc/part'
require 'yayenc/encoder'
require 'yayenc/decoder'

module YAYEnc
  def self.encode(src, options = {}, &block)
    Encoder.encode(src, options, &block)
  end
end
