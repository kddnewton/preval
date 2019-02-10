# frozen_string_literal: true

module Prepack
  module Format
    def self.to(type, &block)
      define_method(:"to_#{type}", &block)
    end

    to(:alias) { "alias #{source(0)} #{source(1)}" }
    to(:aref) { body[1] ? "#{source(0)}[#{source(1)}]" : "#{source(0)}[]" }
    to(:aref_field) { "#{source(0)}[#{source(1)}]" }
    to(:arg_paren) { body[0].nil? ? '' : "(#{source(0)})" }
    to(:args_add) { starts_with?(:args_new) ? source(1) : join(',') }
    to(:args_add_block) do
      args, block = body

      parts = args.is?(:args_new) ? [] : [args.to_source]
      parts << parts.any? ? ',' : "&#{block.to_source}" if block

      parts.join
    end
    to(:args_add_star) { starts_with?(:args_new) ? "*#{source(1)}" : "#{source(0)},*#{source(1)}" }
    to(:args_new) { '' }
    to(:assign) { "#{source(0)} = #{source(1)}" }
    to(:array) { body[0].nil? ? '[]' : "#{starts_with?(:args_add) ? '[' : ''}#{source(0)}]" }
    to(:assoc_new) { starts_with?(:@label) ? join(' ') : join(' => ') }
    to(:assoc_splat) { "**#{source(0)}" }
    to(:assoclist_from_args) { body[0].map(&:to_source).join(',') }
    to(:bare_assoc_hash) { body[0].map(&:to_source).join(',') }
    to(:begin) { "begin\n#{join("\n")}\nend" }
    to(:BEGIN) { "BEGIN {\n#{source(0)}\n}"}
    to(:binary) { "#{source(0)} #{body[1]} #{source(2)}" }
    to(:block_var) { "|#{source(0)}|" }
    to(:bodystmt) do
      source(0).tap do |code|
        code << "\n#{source(1)}" if body[1]

        if body[2]
          stmts = body[2].is?(:else) ? body[2].body[0] : body[2]
          code << "\nelse\n#{stmts.to_source}"
        end

        code << "\n#{source(3)}" if body[3]
      end
    end
    to(:brace_block) { " { #{body[0] ? source(0) : ''}#{source(1)} }" }
    to(:break) { body[0].is?(:args_new) ? 'break' : "break #{source(0)}" }
    to(:call) { "#{source(0)}#{source(1)}#{body[2] === :call ? '' : source(2)}" }
    to(:case) { "case#{body[0] ? " #{source(0)}" : ''}\n#{source(1)}\nend" }
    to(:class) { "class #{source(0)}#{body[1] ? " < #{source(1)}\n" : ''}#{source(2)}\nend" }
    to(:command) { join(' ') }
    to(:command_call) { "#{source(0)}.#{source(2)} #{source(3)}" }
    to(:const_path_field) { join('::') }
    to(:const_path_ref) { join('::') }
    to(:const_ref) { source(0) }
    to(:def) { "def #{source(0)}#{body[1].is?(:paren) ? source(1) : "(#{source(1)})"}\n#{source(2)}\nend" }
    to(:defined) { "defined?(#{source(0)})" }
    to(:do_block) { " do#{body[0] ? " #{source(0)}" : ''}\n#{source(1)}\nend" }
    to(:dot2) { join('..') }
    to(:dot3) { join('...') }
    to(:dyna_symbol) { ":\"#{source(0)}\"" }
    to(:END) { "END {\n#{source(0)}\n}"}
    to(:else) { "else\n#{source(0)}" }
    to(:elsif) { "elsif #{source(0)}\n#{source(1)}#{body[2] ? "\n#{source(2)}" : ''}" }
    to(:ensure) { "ensure\n#{source(0)}" }
    to(:fcall) { join }
    to(:field) { join }
    to(:for) { "#{source(1)}.each do |#{source(0)}|\n#{source(2)}\nend" }
    to(:hash) { body[0].nil? ? '{}' : "{ #{join} }" }
    to(:if) { "if #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    to(:if_mod) { "#{source(1)} if #{source(0)}" }
    to(:ifop) { "#{source(0)} ? #{source(1)} : #{source(2)}"}
    to(:lambda) { "->(#{starts_with?(:paren) ? body[0].body[0].to_source : source(0)}) { #{source(1)} }" }
    to(:massign) { join(' = ') }
    to(:method_add_arg) { body[1].is?(:args_new) ? source(0) : join }
    to(:method_add_block) { join }
    to(:mlhs_add) { starts_with?(:mlhs_new) ? source(1) : join(',') }
    to(:mlhs_add_post) { join(',') }
    to(:mlhs_add_star) { "#{starts_with?(:mlhs_new) ? '' : "#{source(0)},"}#{body[1] ? "*#{source(1)}" : '*'}" }
    to(:mlhs_paren) { "(#{source(0)})" }
    to(:mrhs_add) { join(',') }
    to(:mrhs_add_star) { "*#{join}" }
    to(:mrhs_new) { '' }
    to(:mrhs_new_from_args) { source(0) }
    to(:module) { "module #{source(0)}#{source(1)}\nend" }
    to(:next) { starts_with?(:args_new) ? 'next' : "next #{source(0)}" }
    to(:opassign) { join(' ') }
    to(:paren) { "(#{join})" }
    to(:params) do
      reqs, opts, rest, post, kwargs, kwarg_rest, block = body
      parts = []

      parts += reqs.map(&:to_source) if reqs
      parts += opts.map { |opt| "#{opt[0]} = #{opt[1]}" } if opts
      parts << rest.to_source if rest
      parts += post.map(&:to_source) if post
      parts += kwargs.map { |(kwarg, value)| value ? "#{kwarg.to_source} #{value.to_source}" : kwarg.to_source } if kwargs
      parts << kwarg_rest.to_source if kwarg_rest
      parts << block.to_source if block

      parts.join(',')
    end
    to(:program) { "#{join("\n")}\n" }
    to(:qsymbols_add) { join(starts_with?(:qsymbols_new) ? '' : ' ') }
    to(:qsymbols_new) { '%i[' }
    to(:qwords_add) { join(starts_with?(:qwords_new) ? '' : ' ') }
    to(:qwords_new) { '%w[' }
    to(:redo) { 'redo' }
    to(:regexp_add) { join }
    to(:regexp_new) { '' }
    to(:regexp_literal) { "%r{#{source(0)}}#{source(1).slice(1)}" }
    to(:rescue) do
      'rescue'.dup.tap do |code|
        if body[0] || body[1]
          code << (body[0].is_a?(Array) ? " #{body[0][0].to_source}" : " #{source(0)}") if body[0]
          code << " => #{source(1)}" if body[1]
        end

        code << "\n#{source(2)}"
        code << "\n#{source(3)}" if body[3]
      end
    end
    to(:rescue_mod) { join(' rescue ') }
    to(:rest_param) { body[0] ? "*#{source(0)}" : '*' }
    to(:retry) { 'retry' }
    to(:return) { "return #{source(0)}" }
    to(:return0) { 'return' }
    to(:sclass) { "class << #{source(0)}\n#{source(1)}\nend" }
    to(:stmts_add) { starts_with?(:stmts_new) ? source(1) : join("\n") }
    to(:string_add) { source(0) << source(1) }
    to(:string_concat) { join(" \\\n") }
    to(:string_content) { [] }
    to(:string_dvar) { "\#{#{source(0)}}" }
    to(:string_embexpr) { "\#{#{source(0)}}" }
    to(:string_literal) do
      content =
        source(0).map! do |part|
          part.start_with?('#{') ? part : part.gsub(/([^\\])"/) { "#{$1}\\\"" }
        end

      "\"#{content.join}\""
    end
    to(:super) { "super#{starts_with?(:arg_paren) ? '' : ' '}#{source(0)}" }
    to(:symbol) { ":#{source(0)}" }
    to(:symbol_literal) { source(0) }
    to(:symbols_add) { join(starts_with?(:symbols_new) ? '' : ' ') }
    to(:symbols_new) { '%I[' }
    to(:top_const_field) { "::#{source(0)}" }
    to(:top_const_ref) { "::#{source(0)}" }
    to(:unary) { "#{body[0][0]}#{source(1)}" }
    to(:undef) { "undef #{body[0][0].to_source}" }
    to(:unless) { "unless #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    to(:unless_mod) { "#{source(1)} unless #{source(0)}" }
    to(:until) { "until #{source(0)}\n#{source(1)}\nend" }
    to(:until_mod) { "#{source(1)} until #{source(0)}" }
    to(:var_alias) { "alias #{source(0)} #{source(1)}" }
    to(:var_field) { join }
    to(:var_ref) { source(0) }
    to(:vcall) { join }
    to(:void_stmt) { '' }
    to(:when) { "when #{source(0)}\n#{source(1)}#{body[2] ? "\n#{source(2)}" : ''}" }
    to(:while) { "while #{source(0)}\n#{source(1)}\nend" }
    to(:while_mod) { "#{source(1)} while #{source(0)}" }
    to(:word_add) { join }
    to(:word_new) { '' }
    to(:words_add) { join(starts_with?(:words_new) ? '' : ' ') }
    to(:words_new) { '%W[' }
    to(:xstring_add) { join }
    to(:xstring_new) { '' }
    to(:xstring_literal) { "%x[#{source(0)}]" }
    to(:yield) { "yield#{starts_with?(:paren) ? '' : ' '}#{join}" }
    to(:yield0) { 'yield' }
    to(:zsuper) { 'super' }
  end
end
