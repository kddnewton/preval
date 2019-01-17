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

      private

      def source(index)
        node.body[index].to_source
      end

      def type(index)
        node.body[index].type
      end
    end

    def self.set(*types, &block)
      types.each do |type|
        clazz = Class.new(Node) { define_method(:to_source, &block) }
        const_set(type.upcase, clazz)
      end
    end

    set :alias, :var_alias do
      "alias #{source(0)} #{source(1)}"
    end

    set :aref do
      node.body[1] ? "#{source(0)}[#{source(1)}]" : "#{source(0)}[]"
    end

    set :aref_field do
      "#{source(0)}[#{source(1)}]"
    end

    set :args_add do
      if type(0) == :args_new
        source(1)
      else
        node.body.map(&:to_source).join(',')
      end
    end

    set :args_add_block do
      args, block = node.body

      parts = args.type == :args_new ? [] : [args.to_source]
      parts << parts.any? ? ',' : "&#{block.to_source}" if block

      parts.join
    end

    set :args_add_star do
      star = "*#{source(1)}"
      type(0) == :args_new ? star : "#{source(0)},#{star}"
    end

    set :assign do
      "#{source(0)} = #{source(1)}"
    end

    set :array do
      return '[]' if node.body[0].nil?
      "#{type(0) == :args_add ? '[' : ''}#{source(0)}]"
    end

    set :binary do
      "#{source(0)} #{node.body[1]} #{source(2)}"
    end

    set :defined do
      "defined?(#{source(0)})"
    end

    set :lit_gvar, :lit_ident, :lit_int, :lit_tstring_content do
      node.body
    end

    set :program do
      "#{node.body.map(&:to_source).join("\n")}\n"
    end

    set :qsymbols_add do
      node.body.map(&:to_source).join(type(0) == :qsymbols_new ? '' : ' ')
    end

    set :qsymbols_new do
      "%i["
    end

    set :qwords_add do
      node.body.map(&:to_source).join(type(0) == :qwords_new ? '' : ' ')
    end

    set :qwords_new do
      "%w["
    end

    set :stmts_add do
      if type(0) == :stmts_new
        source(1)
      else
        node.body.map(&:to_source).join("\n")
      end
    end

    set :string_add do
      node.body.map(&:to_source).join
    end

    set :string_content do
      return '' if node.body.length.zero?
      raise ArgumentError
    end

    set :string_embexpr do
      "\#{#{source(0)}}"
    end

    set :string_literal do
      "\"#{source(0)}\""
    end

    set :symbol do
      ":#{source(0)}"
    end

    set :symbol_literal do
      source(0)
    end

    set :symbols_add do
      node.body.map(&:to_source).join(type(0) == :symbols_new ? '' : ' ')
    end

    set :symbols_new do
      "%I["
    end

    set :vcall do
      node.body.map(&:to_source).join
    end

    set :word_add do
      node.body.map(&:to_source).join
    end

    set :word_new do
      ''
    end

    set :words_add do
      node.body.map(&:to_source).join(type(0) == :words_new ? '' : ' ')
    end

    set :words_new do
      "%W["
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
