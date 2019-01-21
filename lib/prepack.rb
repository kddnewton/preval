# frozen_string_literal: true

require 'ripper'

module Prepack
  SyntaxError = Class.new(SyntaxError)

  class << self
    attr_reader :visitors

    def process(source)
      visitors.inject(source) { |accum, visitor| visitor.process(accum) }
    end
  end

  @visitors = []
end

require 'prepack/format'
require 'prepack/node'
require 'prepack/parser'
require 'prepack/version'
require 'prepack/visitor'
require 'prepack/visitors/arithmetic'
require 'prepack/visitors/loops'

Prepack::Visitors::Arithmetic.enable!
Prepack::Visitors::Loops.enable!
