# frozen_string_literal: true

module Prepack
  class Pass
    class ArithmeticPass < Pass
      def on_binary(node)
        left, operation, right = node.body

        if left.type == :@int && %i[+ - * / % **].include?(operation) && right.type == :@int
          value = left.body[0].to_i.public_send(operation, right.body[0].to_i).to_s
          node.update(:@int, value)
        elsif %i[+ -].include?(operation)
          if right.type == :@int && right.body[0] == '0'
            node.replace(left)
          elsif left.type == :@int && left.body[0] == '0'
            node.replace(right)
          end
        elsif %i[* /].include?(operation)
          if right.type == :@int && right.body[0] == '1'
            node.replace(left)
          elsif left.type == :@int && left.body[0] == '1'
            node.replace(right)
          end
        elsif operation == :**
          if right.type == :@int && right.body[0] == '1'
            node.replace(left)
          elsif left.type == :@int && left.body[0] == '1'
            node.replace(left)
          end
        end
      end
    end
  end
end
