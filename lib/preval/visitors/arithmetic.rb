# frozen_string_literal: true

module Preval
  class Visitors
    class Arithmetic < Visitor
      module IntNode
        refine Node do
          def int?(value)
            is?(:@int) && to_int == value
          end

          def to_int
            body[0].to_i
          end
        end
      end

      using IntNode

      OPERATORS = %i[+ - * / % **].freeze

      def on_binary(node)
        left, operation, right = node.body

        if left.is?(:@int) && OPERATORS.include?(operation) && right.is?(:@int)
          value = left.to_int.public_send(operation, right.to_int).to_s
          node.update(:@int, value)
        elsif %i[+ -].include?(operation)
          if right.int?(0)
            node.replace(left)
          elsif left.int?(0)
            node.replace(right)
          end
        elsif %i[* /].include?(operation)
          if right.int?(1)
            node.replace(left)
          elsif left.int?(1)
            node.replace(right)
          end
        elsif operation == :**
          if left.is?(:@int) && right.int?(0)
            node.update(:@int, left.to_int < 0 ? -1 : 1)
          elsif right.int?(1)
            node.replace(left)
          elsif left.int?(1)
            node.replace(left)
          end
        end
      end
    end
  end
end
