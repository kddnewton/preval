# frozen_string_literal: true

module Preval
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

      def on_for(node)
        sexp = Parser.parse(<<~CODE)
          #{node.source(1)}.each do |#{node.source(0)}|
            #{node.source(2)}
          end
        CODE

        node.update(:stmts_add, sexp.body[0].body)
      end

      def on_while(node)
        return unless node.body[0].true?

        sexp = Parser.parse(<<~CODE)
          loop do
            #{node.source(1)}
          end
        CODE

        node.update(:stmts_add, sexp.body[0].body)
      end
    end
  end
end
