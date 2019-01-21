# frozen_string_literal: true

module Prepack
  class Pass
    class ArithmeticPass < Pass
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
          if right.int?(1)
            node.replace(left)
          elsif left.int?(1)
            node.replace(left)
          end
        end
      end
    end
  end
end
