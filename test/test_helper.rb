$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'preval'

Preval::Visitors::Arithmetic.enable!
Preval::Visitors::Loops.enable!
Preval::Visitors::Micro.enable!

require 'minitest/autorun'
