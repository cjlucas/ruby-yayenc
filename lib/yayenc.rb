require 'yayenc/part'
require 'yayenc/encoder'

module YAYEnc
  def self.encode(src, **options, &block)
    Encoder.encode(src, options, &block)
  end
end
