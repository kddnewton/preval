# frozen_string_literal: true

module Preval
  class Node
    class TypeMatch
      attr_reader :types

      def initialize(types)
        @types = types
      end

      def match?(node)
        node.body.size == types.size &&
          node.body.zip(types).all? do |(left, right)|
            left.is_a?(Node) && Array(right).include?(left.type)
          end
      end

      def self.match?(types, node)
        new(types).match?(node)
      end
    end

    include Format

    attr_reader :type, :body, :literal

    def initialize(type, body, literal = false)
      @type = type
      @body = body
      @literal = literal
    end

    def [](index, *args)
      node = body[index]
      return nil unless node

      args.any? ? node[*args] : node
    end

    def join(delim = '')
      body.map(&:to_source).join(delim)
    end

    def is?(other)
      type == other
    end

    def replace(node)
      @type = node.type
      @body = node.body
      @literal = node.literal
    end

    def source(index)
      body[index].to_source
    end

    def starts_with?(type)
      body[0].is?(type)
    end

    def to_source
      return body if literal

      begin
        public_send(:"to_#{type}")
      rescue NoMethodError
        raise NotImplementedError, "#{type} has not yet been implemented"
      end
    end

    def type_match?(*types)
      TypeMatch.new(types).match?(self)
    end

    def update(type, body)
      @type = type
      @body = body
      @literal = type.to_s.start_with?('@')
    end

    def visit(pass)
      return if literal

      handler = :"on_#{type}"
      pass.public_send(handler, self) if pass.respond_to?(handler)

      return unless body.is_a?(Array)

      body.each do |child|
        child.visit(pass) if child.is_a?(Node)
      end
    end
  end
end
