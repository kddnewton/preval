$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'prepack'

Prepack::Visitors::Arithmetic.enable!
Prepack::Visitors::Loops.enable!

require 'minitest/autorun'
