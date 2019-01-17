require 'ripper'
require 'prepack/version'

module Prepack
  class << self
    attr_accessor :passes

    def process(source)
      passes.each do |pass|
        source = pass.process(source)
      end
      source
    end
  end

  self.passes = []
end

module Prepack
  module Translate
    class Node
      attr_reader :node

      def initialize(node)
        @node = node
      end
    end

    def self.set(*types, &block)
      types.each do |type|
        const_set(type, Class.new(Node) { define_method(:to_source, &block) })
      end
    end

    set :ALIAS, :VAR_ALIAS do
      left, right = node.body
      "alias #{left.to_source} #{right.to_source}"
    end

    set :BINARY do
      left, op, right = node.body
      "#{left.to_source} #{op} #{right.to_source}"
    end

    set :DEFINED do
      "defined?(#{node.body[0].to_source})"
    end

    set :LIT_GVAR, :LIT_IDENT, :LIT_INT do
      node.body
    end

    set :PROGRAM do
      "#{node.body.map(&:to_source).join("\n")}\n"
    end

    set :STMTS_ADD do
      if node.body[0].type == :stmts_new
        node.body[1].to_source
      else
        node.body.map(&:to_source).join("\n")
      end
    end

    set :SYMBOL do
      ":#{node.body[0].to_source}"
    end

    set :SYMBOL_LITERAL do
      node.body[0].to_source
    end

    set :VCALL do
      node.body.map(&:to_source).join
    end
  end
end

module Prepack
  class Node
    attr_reader :type, :body

    def initialize(type, body)
      @type = type
      @body = body
    end

    def each_child
      return if type.to_s.start_with?('lit_')

      body.each do |child|
        yield child if child.is_a?(Node)
      end
    end

    def replace(type, body)
      @type = type
      @body = body
    end

    def to_source
      Translate.const_get(type.upcase).new(self).to_source
    end
  end
end

module Prepack
  class Parser < Ripper::SexpBuilder
    def self.sexp(src, filename = '-', lineno = 1)
      new(src, filename, lineno).parse
    end

    private

    SCANNER_EVENTS.each do |event|
      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(token)
          Node.new(:lit_#{event}, token)
        end
      End
    end

    events = private_instance_methods(false).grep(/\Aon_/) { $'.to_sym }
    (PARSER_EVENTS - events).each do |event|
      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(*args)
          Node.new(:#{event}, args)
        end
      End
    end
  end
end

module Prepack
  class Pass
    def process(source)
      node = Prepack::Parser.sexp(source)
      dispatch(node)
      node.to_source
    end

    def self.enable!
      Prepack.passes << new
    end

    private

    def dispatch(node)
      processor = :"on_#{node.type}"
      public_send(processor, node) if respond_to?(processor)
      node.each_child { |child| dispatch(child) }
    end
  end
end

module Prepack
  class Matcher
    module Matches
      refine Object do
        def matches?(value)
          self == value
        end
      end

      refine Node do
        def matches?(value)
          type == value
        end
      end
    end

    using Matches

    attr_reader :pattern

    def initialize(*pattern)
      @pattern = pattern
    end

    def match?(node)
      node.body.each.with_index.all? do |child, index|
        if pattern[index].is_a?(Array)
          pattern[index].any? { |candidate| child.matches?(candidate) }
        else
          child.matches?(pattern[index])
        end
      end
    end
  end
end

module Prepack
  class ArithmeticPass < Pass
    attr_reader :literal_binary

    def initialize
      @literal_binary = Matcher.new(:lit_int, %i[+ - * / % **], :lit_int)
    end

    def on_binary(node)
      if literal_binary.match?(node)
        left, op, right = node.body
        value = left.body[0].to_i.public_send(op, right.body[0].to_i)
        node.replace(:lit_int, value.to_s)
      end
    end
  end
end

Prepack::ArithmeticPass.enable!
