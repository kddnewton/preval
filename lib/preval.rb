# frozen_string_literal: true

require 'ripper'

module Preval
  SyntaxError = Class.new(SyntaxError)

  class << self
    attr_reader :visitors

    def process(source)
      visitors.inject(Parser.parse(source)) do |current, visitor|
        current.tap { |ast| ast.visit(visitor) }
      end.to_source
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
require 'preval/visitors/attr_accessor'
require 'preval/visitors/loops'
require 'preval/visitors/micro'

if defined?(Bootsnap)
  load_iseq = RubyVM::InstructionSequence.method(:load_iseq)

  if load_iseq.source_location[0].include?('/bootsnap/')
    Bootsnap::CompileCache::ISeq.singleton_class.prepend(
      Module.new do
        def input_to_storage(source, path)
          source = Preval.process(source)
          RubyVM::InstructionSequence.compile(source, path, path).to_binary
        rescue SyntaxError
          raise Bootsnap::CompileCache::Uncompilable, 'syntax error'
        end
      end
    )
  end
end
