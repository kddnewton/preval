require 'ripper'
require 'prepack/version'

module Prepack
  class << self
    attr_accessor :passes

    def process(source)
      passes.inject(source) { |accum, pass| pass.process(accum) }
    end
  end

  self.passes = []
end

module Prepack
  class Node
    attr_reader :type, :body, :literal

    def initialize(type, body, literal = false)
      @type = type
      @body = body
      @literal = literal
    end

    def replace(type, body)
      @type = type
      @body = body
      @literal = type.to_s.start_with?('@')
    end

    def starts?(type)
      body[0].type == type
    end

    def to_source
      return body if literal

      begin
        public_send(:"to_#{type}_source")
      rescue NoMethodError
        raise NotImplementedError, "#{type} has not yet been implemented"
      end
    end

    def visit(pass)
      return if literal

      handler = :"on_#{type}"
      pass.public_send(handler, self) if pass.respond_to?(handler)

      return unless body.is_a?(Array)

      body.each do |child|
        child.visit(pass) if child.is_a?(Node)
      end
    end

    def self.set(*types, &block)
      types.each do |type|
        define_method(:"to_#{type}_source", &block)
      end
    end

    set(:alias, :var_alias) { "alias #{source(0)} #{source(1)}" }
    set(:aref) { body[1] ? "#{source(0)}[#{source(1)}]" : "#{source(0)}[]" }
    set(:aref_field) { "#{source(0)}[#{source(1)}]" }
    set(:arg_paren) { body[0].nil? ? '' : "(#{source(0)})" }
    set(:args_add) { starts?(:args_new) ? source(1) : join(',') }
    set(:args_add_block) do
      args, block = body

      parts = args.type == :args_new ? [] : [args.to_source]
      parts << parts.any? ? ',' : "&#{block.to_source}" if block

      parts.join
    end
    set(:args_add_star) { starts?(:args_new) ? "*#{source(1)}" : "#{source(0)},*#{source(1)}" }
    set(:args_new) { '' }
    set(:assign) { "#{source(0)} = #{source(1)}" }
    set(:array) { body[0].nil? ? '[]' : "#{starts?(:args_add) ? '[' : ''}#{source(0)}]" }
    set(:begin) { "begin\n#{join("\n")}\nend" }
    set(:BEGIN) { "BEGIN {\n#{source(0)}\n}"}
    set(:binary) { "#{source(0)} #{body[1]} #{source(2)}" }
    set(:block_var) { "|#{source(0)}|" }
    set(:bodystmt) { body.compact.map(&:to_source).join("\n") }
    set(:brace_block) { " { #{body[0] ? source(0) : ''}#{source(1)} }" }
    set(:call) { "#{source(0)}#{source(1)}#{body[2] === 'call' ? '' : source(2)}" }
    set(:class) { "class #{source(0)}#{body[1] ? " < #{source(1)}\n" : ''}#{source(2)}\nend" }
    set(:command) { join(' ') }
    set(:const_path_field, :const_path_ref) { join('::') }
    set(:const_ref) { source(0) }
    set(:def) { "def #{source(0)}\n#{source(2)}\nend" }
    set(:defined) { "defined?(#{source(0)})" }
    set(:do_block) { " do#{body[0] ? " #{source(0)}" : ''}\n#{source(1)}\nend" }
    set(:END) { "END {\n#{source(0)}\n}"}
    set(:else) { "else\n#{source(0)}" }
    set(:elsif) { "elsif #{source(0)}\n#{source(1)}#{body[2] ? "\n#{source(2)}" : ''}" }
    set(:fcall) { join }
    set(:field) { join }
    set(:if) { "if #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    set(:if_mod) { "#{source(1)} if #{source(0)}" }
    set(:ifop) { "#{source(0)} ? #{source(1)} : #{source(2)}"}
    set(:massign) { join(' = ') }
    set(:method_add_arg) { body[1].type == :args_new ? source(0) : join }
    set(:method_add_block) { join }
    set(:mlhs_add) { starts?(:mlhs_new) ? source(1) : join(',') }
    set(:mlhs_add_post) { join(',') }
    set(:mlhs_add_star) { "#{starts?(:mlhs_new) ? '' : "#{source(0)},"}#{body[1] ? "*#{source(1)}" : '*'}" }
    set(:mlhs_paren) { "(#{source(0)})" }
    set(:mrhs_add) { join(',') }
    set(:mrhs_add_star) { "*#{join}" }
    set(:mrhs_new) { '' }
    set(:mrhs_new_from_args) { source(0) }
    set(:module) { "module #{source(0)}#{source(1)}\nend" }
    set(:next) { starts?(:args_new) ? 'next' : "next #{source(0)}" }
    set(:opassign) { join(' ') }
    set(:paren) { "(#{join})" }
    set(:params) do
      reqs, opts, rest, post, kwargs, kwarg_rest, block = body
      parts = []

      parts << reqs.map(&:to_source).join if reqs
      parts += opts.map { |opt| "#{opt[0]} = #{opt[1]}" } if opts
      parts << rest.to_source if rest
      parts << post.map(&:to_source).join if post
      parts += kwargs.map { |(kwarg, value)| value ? "#{kwarg} #{value}" : kwarg } if kwargs
      parts << kwarg_rest.to_source if kwarg_rest
      parts << block.to_source if block

      parts.join(',')
    end
    set(:program) { "#{join("\n")}\n" }
    set(:qsymbols_add) { join(starts?(:qsymbols_new) ? '' : ' ') }
    set(:qsymbols_new) { '%i[' }
    set(:qwords_add) { join(starts?(:qwords_new) ? '' : ' ') }
    set(:qwords_new) { '%w[' }
    set(:sclass) { "class << #{source(0)}\n#{source(1)}\nend" }
    set(:stmts_add) { starts?(:stmts_new) ? source(1) : join("\n") }
    set(:string_add, :var_field, :vcall, :word_add) { join }
    set(:string_content) { '' }
    set(:string_embexpr) { "\#{#{source(0)}}" }
    set(:string_literal) { "\"#{source(0)}\"" }
    set(:super) { "super#{starts?(:arg_paren) ? '' : ' '}#{source(0)}" }
    set(:symbol) { ":#{source(0)}" }
    set(:symbol_literal) { source(0) }
    set(:symbols_add) { join(starts?(:symbols_new) ? '' : ' ') }
    set(:symbols_new) { '%I[' }
    set(:top_const_field, :top_const_ref) { "::#{source(0)}" }
    set(:undef) { "undef #{body[0][0].to_source}" }
    set(:unless) { "unless #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    set(:unless_mod) { "#{source(1)} unless #{source(0)}" }
    set(:until) { "until #{source(0)}\n#{source(1)}\nend" }
    set(:until_mod) { "#{source(1)} until #{source(0)}" }
    set(:var_ref) { source(0) }
    set(:void_stmt) { '' }
    set(:while) { "while #{source(0)}\n#{source(1)}\nend" }
    set(:while_mod) { "#{source(1)} while #{source(0)}" }
    set(:word_new) { '' }
    set(:words_add) { join(starts?(:words_new) ? '' : ' ') }
    set(:words_new) { '%W[' }
    set(:yield) { "yield#{starts?(:paren) ? '' : ' '}#{join}" }
    set(:yield0) { 'yield' }
    set(:zsuper) { 'super' }

    private

    def join(delim = '')
      body.map(&:to_source).join(delim)
    end

    def source(index)
      body[index].to_source
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
          Node.new(:@#{event}, token, true)
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
      Parser.sexp(source).tap { |node| node.visit(self) }.to_source
    end

    def self.enable!
      Prepack.passes << new
    end
  end
end

module Prepack
  class ArithmeticPass < Pass
    def on_binary(node)
      left, op, right = node.body
      return if left.type != :@int || !%i[+ - * / % **].include?(op) || right.type != :@int

      value = left.body[0].to_i.public_send(op, right.body[0].to_i).to_s
      node.replace(:@int, value)
    end
  end
end

module Prepack
  class LoopPass < Pass
    def on_while(node)
      predicate, statements = node.body
      return if predicate.type != :var_ref || predicate.body[0].type != :@kw || predicate.body[0].body != 'true'

      node.replace(:stmts_add, Parser.sexp("loop do\n#{statements.to_source}\nend").body[0].body)
    end
  end
end

Prepack::ArithmeticPass.enable!
Prepack::LoopPass.enable!
