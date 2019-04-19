# frozen_string_literal: true

module Preval
  class Visitors
    class Loops < Visitor
      def on_for(node)
        ast = Parser.parse(<<~CODE)
          #{node.source(1)}.each do |#{node.source(0)}|
            #{node.source(2)}
          end
        CODE

        node.update(:stmts_add, ast[0].body)
      end

      def on_while(node)
        # auto replace while true with loop do
        if node[0].is?(:var_ref) &&
             # the predicate to the while is a variable reference
           node[0, 0].is?(:@kw) &&
             # the variable reference is a keyword
           node[0, 0].body == 'true'
             # the keyword is "true"

          ast = Parser.parse(<<~CODE)
            loop do
              #{node.source(1)}
            end
          CODE

          node.update(:stmts_add, ast[0].body)
        end
      end
    end
  end
end
