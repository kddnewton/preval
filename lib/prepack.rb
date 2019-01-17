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

      def join(delim = '')
        node.body.map(&:to_source).join(delim)
      end

      def starts?(type)
        node.body[0].type == type
      end

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

    set(:alias, :var_alias) { "alias #{source(0)} #{source(1)}" }
    set(:aref) { node.body[1] ? "#{source(0)}[#{source(1)}]" : "#{source(0)}[]" }
    set(:aref_field) { "#{source(0)}[#{source(1)}]" }
    set(:args_add) { starts?(:args_new) ? source(1) : join(',') }

    set :args_add_block do
      args, block = node.body

      parts = args.type == :args_new ? [] : [args.to_source]
      parts << parts.any? ? ',' : "&#{block.to_source}" if block

      parts.join
    end

    set(:args_add_star) { starts?(:args_new) ? "*#{source(1)}" : "#{source(0)},*#{source(1)}" }
    set(:assign) { "#{source(0)} = #{source(1)}" }
    set(:array) { node.body[0].nil? ? '[]' : "#{starts?(:args_add) ? '[' : ''}#{source(0)}]" }
    set(:begin) { "begin\n#{join("\n")}\nend" }
    set(:binary) { "#{source(0)} #{node.body[1]} #{source(2)}" }
    set(:bodystmt) { node.body.compact.map(&:to_source).join("\n") }
    set(:defined) { "defined?(#{source(0)})" }
    set(:field) { join }
    set(:lit_gvar, :lit_ident, :lit_int, :lit_op, :lit_period, :lit_tstring_content) { node.body }
    set(:massign) { join(' = ') }
    set(:mlhs_add) { starts?(:mlhs_new) ? source(1) : join(',') }
    set(:mlhs_add_post) { join(',') }
    set(:mlhs_add_star) { "#{starts?(:mlhs_new) ? '' : "#{source(0)},"}#{node.body[1] ? "*#{source(1)}" : '*'}" }
    set(:mlhs_paren) { "(#{source(0)})" }
    set(:mrhs_add) { join(',') }
    set(:mrhs_add_star) { "*#{join}" }
    set(:mrhs_new) { '' }
    set(:mrhs_new_from_args) { source(0) }
    set(:opassign) { join(' ') }
    set(:program) { "#{join("\n")}\n" }
    set(:qsymbols_add) { join(starts?(:qsymbols_new) ? '' : ' ') }
    set(:qsymbols_new) { '%i[' }
    set(:qwords_add) { join(starts?(:qwords_new) ? '' : ' ') }
    set(:qwords_new) { '%w[' }
    set(:stmts_add) { starts?(:stmts_new) ? source(1) : join("\n") }
    set(:string_add, :var_field, :vcall, :word_add) { join }
    set(:string_content) { '' }
    set(:string_embexpr) { "\#{#{source(0)}}" }
    set(:string_literal) { "\"#{source(0)}\"" }
    set(:symbol) { ":#{source(0)}" }
    set(:symbol_literal) { source(0) }
    set(:symbols_add) { join(starts?(:symbols_new) ? '' : ' ') }
    set(:symbols_new) { '%I[' }
    set(:var_ref) { source(0) }
    set(:word_new) { '' }
    set(:words_add) { join(starts?(:words_new) ? '' : ' ') }
    set(:words_new) { '%W[' }
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
