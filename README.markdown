YAYEnc is a 100% Ruby yEnc encoder (no decoder yet).

Disclaimer: This is considered alpha software, so the API may change without warning

[![Build Status (master)](https://travis-ci.org/cjlucas/ruby-yayenc.png?branch=master "Branch: master")](https://travis-ci.org/cjlucas/ruby-yayenc)
[![Coverage Status](https://coveralls.io/repos/cjlucas/ruby-yayenc/badge.png?branch=master)](https://coveralls.io/r/cjlucas/ruby-yayenc?branch=master)

---
## Synopsis ##
```ruby
require 'yayenc'

# get an array of yEnc encoded part(s)
parts = YAYEnc::Encoder.encode('spec/files/test1.txt')

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
  - 1.9.3
  - 2.0.0
  - 2.1.0

## TODO ##
- Documentation
- Decoder
- Threading support
