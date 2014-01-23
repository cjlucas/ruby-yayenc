YAYEnc is a 100% ruby yEnc encoder (no decoder yet).

---
## Synopsis ##
```ruby
require 'yayenc'

encoder = YAYEnc::Encoder.new('spec/files/test1.txt')
parts = encoder.encode # get an array of yEnc encoded part(s)

# Or you may use the preferred block interface

# IO objects are also supported, but a filename must be specified
YAYEnc::Encoder.encode(File.open('spec/files/test1.txt', 'rb'), :name => 'test1.txt') do |part|
  part.pcrc32.to_s(16)
  # => "ded29f4f"
  
  part.part_num
  # => 1
  part.part_total
  # => 1
  part.final_part?
  # => true
  
  puts part
  # =ybegin line=128 name=test1.txt
  # ... encoded data ...
  # =yend size=584 crc32=ded29f4f
end

```
## Requirements ##
- Supported Ruby Versions
  - 1.8.7 
  - 1.9
  - 2.0

## TODO ##
- Documentation
- Decoder
- Threading support
