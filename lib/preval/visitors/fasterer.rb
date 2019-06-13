# frozen_string_literal: true

module Preval
  class Visitors
    # All of these optimizations come from the `fasterer` gem.
    class Fasterer < Visitor
      def on_call(node)
        left, _period, right = node.body

        # replace `.reverse.each` with `.reverse_each`
        # replace `.shuffle.first` with `.sample`
        # replace `.sort.first` with `min`
        # replace `.sort.last` with `max`
        if node.type_match?(:call, :@period, :@ident) &&
           # foo.each
           left.type_match?(%i[array vcall], :@period, :@ident)
           # foo.reverse

          callleft, callperiod, callright = left.body

          if callright.body == 'reverse' && right.body == 'each'
            callright.update(:@ident, 'reverse_each')
            node.update(:call, [callleft, callperiod, callright])
          elsif callright.body == 'sort' && right.body == 'first'
            callright.update(:@ident, 'min')
            node.update(:call, [callleft, callperiod, callright])
          elsif callright.body == 'sort' && right.body == 'last'
            callright.update(:@ident, 'max')
            node.update(:call, [callleft, callperiod, callright])
          elsif callright.body == 'shuffle' && right.body == 'first'
            callright.update(:@ident, 'sample')
            node.update(:call, [callleft, callperiod, callright])
          end
        end
      end

      def on_method_add_arg(node)
        # replace `.gsub('...', '...')` with `.tr('...', '...')`
        if node.type_match?(:call, :arg_paren) &&
           # foo.gsub()
           node[0].type_match?(:vcall, :@period, :@ident) &&
           # foo.gsub
           node[0, 2].body == 'gsub'
           # the method being called is gsub

          left = node[1, 0, 0, 0, 1]
          right = node[1, 0, 0, 1]

          if left.is?(:string_literal) &&
             right.is?(:string_literal) &&
             [left, right].all? do |string|
               string[0, 1].is?(:@tstring_content) &&
               string[0, 1].body.length == 1
             end

            node[0, 2].update(:@ident, 'tr')
          end
        end

        # replace `.map { ... }.flatten(1)` with `.flat_map { ... }`
        if node.type_match?(:call, :arg_paren) &&
           # foo.flatten()
           node[0].type_match?(:method_add_block, :@period, :@ident) &&
           # foo.map {}
           node[0, 0, 0].type_match?(%i[array vcall], :@period, :@ident) &&
           # foo.flatten
           node[0, 0, 0, 2].body == 'map' &&
           # the inner call is a call to map
           node[0, 2].body == 'flatten' &&
           # the outer call is a call to flatten
           node[1].is?(:arg_paren) &&
           # flatten has a param
           node[1, 0, 0].type_match?(:args_new, :@int) &&
           # there is only one argument to flatten and it is an integer
           node[1, 0, 0, 1].body == '1'
           # the value of the argument to flatten is 1

          node[0, 0, 0, 2].update(:@ident, 'flat_map')
          node.update(:method_add_block, node[0, 0].body)
        end
      end
    end
  end
end
