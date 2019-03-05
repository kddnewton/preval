$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'preval'

Preval::Visitors::Arithmetic.enable!
Preval::Visitors::Loops.enable!

require 'minitest/autorun'
