# frozen_string_literal: true

module Preval
  class Visitors
    class Micro < Visitor
      class ArrayMatch
        attr_reader :types

        def initialize(types)
          @types = types
        end

        def match?(node)
          node.body.size == types.size &&
            node.body.zip(types).all? do |(left, right)|
              Array(right).include?(left.type)
            end
        end

        def self.match?(types, node)
          new(types).match?(node)
        end
      end

      def on_call(node)
        left, _period, right = node.body

        if ArrayMatch.match?(%i[call @period @ident], node) && right.body == 'each'
          callleft, callperiod, callright = left.body

          if ArrayMatch.match?([%i[array vcall], :@period, :@ident], left) && callright.body == 'reverse'
            callright.update(:@ident, 'reverse_each')
            node.update(:call, [callleft, callperiod, callright])
          end
        end
      end
    end
  end
end
