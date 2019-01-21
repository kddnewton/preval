# frozen_string_literal: true

module Prepack
  class Pass
    class LoopPass < Pass
      def on_while(node)
        predicate, statements = node.body
        return if predicate.type != :var_ref || !predicate.starts_with?(:@kw) || predicate.body[0].body != 'true'

        parser = Parser.new("loop do\n#{statements.to_source}\nend")
        node.update(:stmts_add, parser.parse.body[0].body)
      end
    end
  end
end
