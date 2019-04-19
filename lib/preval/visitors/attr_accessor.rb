# frozen_string_literal: true

module Preval
  class Visitors
    class AttrAccessor < Visitor
      def on_def(node)
        if node.type_match?(:@ident, :params, :bodystmt) &&
           node.body[1].body.none? &&
           node.dig(2, 0, 0).is?(:stmts_new)
          var_ref = node.dig(2, 0, 1)

          if var_ref.is?(:var_ref) &&
             var_ref.type_match?(:@ivar) &&
             node.body[0].body == var_ref.body[0].body[1..-1]

            ast = Parser.parse("attr_reader :#{node.body[0].body}")
            node.update(:stmts_add, ast.body[0].body)
          end
        elsif node.type_match?(:@ident, :paren, :bodystmt) &&
                # def foo(bar); end
              node.dig(0).body.end_with?('=') &&
                # this is a setter method
              node.dig(1, 0, 0).length == 1 &&
                # there is exactly one required param
              node.dig(1, 0).body[1..-1].none? &&
                # there are no other params
              node.dig(2, 0, 0, 0)&.is?(:stmts_new) &&
                # there is only one statement in the body
              node.dig(2, 0, 1).is?(:assign) &&
                # the only statement is an assignment
              node.dig(2, 0, 1).type_match?(:var_field, :var_ref) &&
                # assigning a variable
              node.dig(2, 0, 1, 0, 0).is?(:@ivar) &&
                # assigning to an instance variable
              node.dig(0).body[0..-2] == node.dig(2, 0, 1, 0, 0).body[1..-1] &&
                # variable name matches the method name
              node.dig(1, 0, 0)[0].body == node.dig(2, 0, 1, 1, 0).body
                # assignment variable matches the argument name

          ast = Parser.parse("attr_writer :#{node.dig(0).body[0..-2]}")
          node.update(:stmts_add, ast.body[0].body)
        end
      end
    end
  end
end
