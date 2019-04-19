# frozen_string_literal: true

module Preval
  class Visitors
    class Micro < Visitor
      def on_call(node)
        left, _period, right = node.body

        if node.type_match?(:call, :@period, :@ident) && right.body == 'each'
          callleft, callperiod, callright = left.body

          if left.type_match?(%i[array vcall], :@period, :@ident) && callright.body == 'reverse'
            callright.update(:@ident, 'reverse_each')
            node.update(:call, [callleft, callperiod, callright])
          end
        end
      end

      def on_def(node)
        if node.type_match?(:@ident, :params, :bodystmt) &&
           node.body[1].body.none? &&
           node.dig(2, 0, 0).is?(:stmts_new) &&

          var_ref = node.dig(2, 0, 1)

          if var_ref.is?(:var_ref) &&
             var_ref.type_match?(:@ivar) &&
             node.body[0].body == var_ref.body[0].body[1..-1]

            sexp = Parser.parse("attr_reader :#{node.body[0].body}")
            node.update(:stmts_add, sexp.body[0].body)
          end
        end
      end

      def on_method_add_arg(node)
        if node.type_match?(:call, :arg_paren) &&
           node.body[0].type_match?(:vcall, :@period, :@ident) &&
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
        end
      end
    end
  end
end
