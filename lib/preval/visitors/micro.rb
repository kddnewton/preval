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
