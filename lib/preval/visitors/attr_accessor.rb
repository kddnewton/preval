# frozen_string_literal: true

module Preval
  class Visitors
    class AttrAccessor < Visitor
      def on_def(node)
        # auto create attr_readers
        if node.type_match?(:@ident, :params, :bodystmt) &&
             # def foo; @foo; end
           node[1].body.none? &&
             # there are no params to this method
           node[2, 0].type_match?(:stmts_new, :var_ref) &&
             # there is only one statement in the body and its a var reference
           node[2, 0, 1, 0].is?(:@ivar) &&
             # the var reference is referencing an instance variable
           node[0].body == node[2, 0, 1, 0].body[1..-1]
             # the name of the variable matches the name of the method

          ast = Parser.parse("attr_reader :#{node[0].body}")
          node.update(:stmts_add, ast.body[0].body)
        end

        # auto create attr_writers
        if node.type_match?(:@ident, :paren, :bodystmt) &&
             # def foo=(value); @foo = value; end
           node[0].body.end_with?('=') &&
             # this is a setter method
           node[1, 0, 0].length == 1 &&
             # there is exactly one required param
           node[1, 0].body[1..-1].none? &&
             # there are no other params
           node[2, 0, 0, 0]&.is?(:stmts_new) &&
             # there is only one statement in the body
           node[2, 0, 1].is?(:assign) &&
             # the only statement is an assignment
           node[2, 0, 1].type_match?(:var_field, :var_ref) &&
             # assigning a variable
           node[2, 0, 1, 0, 0].is?(:@ivar) &&
             # assigning to an instance variable
           node[0].body[0..-2] == node[2, 0, 1, 0, 0].body[1..-1] &&
             # variable name matches the method name
           node[1, 0, 0][0].body == node[2, 0, 1, 1, 0].body
             # assignment variable matches the argument name

          ast = Parser.parse("attr_writer :#{node[0].body[0..-2]}")
          node.update(:stmts_add, ast.body[0].body)
        end
      end
    end
  end
end
