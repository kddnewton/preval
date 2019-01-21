# frozen_string_literal: true

module Prepack
  class Pass
    class LoopPass < Pass
      module TrueNode
        refine Node do
          def true?
            is?(:var_ref) && starts_with?(:@kw) && body[0].body == 'true'
          end
        end
      end

      using TrueNode

      def on_while(node)
        predicate, statements = node.body
        return unless predicate.true?

        parser = Parser.new("loop do\n#{statements.to_source}\nend")
        node.update(:stmts_add, parser.parse.body[0].body)
      end
    end
  end
end
