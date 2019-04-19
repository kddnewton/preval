# frozen_string_literal: true

module Preval
  class Visitors
    class Micro < Visitor
      def on_call(node)
        left, _period, right = node.body

        if node.type_match?(:call, :@period, :@ident) && left.type_match?(%i[array vcall], :@period, :@ident)
          callleft, callperiod, callright = left.body

          if callright.body == 'reverse' && right.body == 'each'
            callright.update(:@ident, 'reverse_each')
            node.update(:call, [callleft, callperiod, callright])
          elsif callright.body == 'shuffle' && right.body == 'first'
            callright.update(:@ident, 'sample')
            node.update(:call, [callleft, callperiod, callright])
          end
        end
      end

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

      def on_method_add_arg(node)
        if node.type_match?(:call, :arg_paren)
          if node.body[0].type_match?(:vcall, :@period, :@ident) &&
             node.dig(0, 2).body == 'gsub'

            left = node.dig(1, 0, 0, 0, 1)
            right = node.dig(1, 0, 0, 1)

            if left.is?(:string_literal) &&
               right.is?(:string_literal) &&
               [left, right].all? do |node|
                 node.dig(0, 1).is?(:@tstring_content) &&
                 node.dig(0, 1).body.length == 1
               end

              node.dig(0, 2).update(:@ident, 'tr')
            end
          elsif node.dig(0).type_match?(:method_add_block, :@period, :@ident) &&
                  # foo.map {}
                node.dig(0, 0, 0).type_match?(%i[array vcall], :@period, :@ident) &&
                  # foo.flatten
                node.dig(0, 0, 0, 2).body == 'map' &&
                  # the inner call is a call to map
                node.dig(0, 2).body == 'flatten' &&
                  # the outer call is a call to flatten
                node.dig(1).is?(:arg_paren) &&
                  # flatten has a param
                node.dig(1, 0, 0, 0).is?(:args_new) &&
                  # there is only one argument to flatten
                node.dig(1, 0, 0, 1).is?(:@int) &&
                  # the argument to flatten is an integer
                node.dig(1, 0, 0, 1).body == '1'
                  # the value of the argument to flatten is 1

            node.dig(0, 0, 0, 2).update(:@ident, 'flat_map')
            node.update(:method_add_block, node.dig(0, 0).body)
          end
        end
      end
    end
  end
end
