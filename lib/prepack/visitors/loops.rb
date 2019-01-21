# frozen_string_literal: true

module Prepack
  class Visitors
    class Loops < Visitor
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

        sexp = Parser.parse("loop do\n#{statements.to_source}\nend")
        node.update(:stmts_add, sexp.body[0].body)
      end
    end
  end
end
