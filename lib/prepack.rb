# frozen_string_literal: true

require 'ripper'

module Prepack
  SyntaxError = Class.new(SyntaxError)

  class << self
    attr_reader :passes

    def process(source)
      passes.inject(source) { |accum, pass| pass.process(accum) }
    end
  end

  @passes = []
end

require 'prepack/node'
require 'prepack/parser'
require 'prepack/pass'
require 'prepack/pass/arithmetic_pass'
require 'prepack/pass/loop_pass'
require 'prepack/version'

Prepack::Pass::ArithmeticPass.enable!
Prepack::Pass::LoopPass.enable!
