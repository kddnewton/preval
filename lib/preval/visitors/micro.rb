# frozen_string_literal: true

module Preval
  class Visitors
    class Micro < Visitor
      def on_call(node)
        left, _period, right = node.body

        if node.type_match?(%i[call @period @ident]) && right.body == 'each'
          callleft, callperiod, callright = left.body

          if left.type_match?([%i[array vcall], :@period, :@ident]) && callright.body == 'reverse'
            callright.update(:@ident, 'reverse_each')
            node.update(:call, [callleft, callperiod, callright])
          end
        end
      end
    end
  end
end
