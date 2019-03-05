# frozen_string_literal: true

require 'ripper'

module Preval
  SyntaxError = Class.new(SyntaxError)

  class << self
    attr_reader :visitors

    def process(source)
      visitors.inject(source) { |accum, visitor| visitor.process(accum) }
    end
  end

  @visitors = []
end

require 'preval/format'
require 'preval/node'
require 'preval/parser'
require 'preval/version'
require 'preval/visitor'
require 'preval/visitors/arithmetic'
require 'preval/visitors/loops'
