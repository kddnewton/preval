# frozen_string_literal: true

module Preval
  class Visitor
    def process(source)
      sexp = Parser.parse(source)
      sexp.tap { |node| node.visit(self) }.to_source if sexp
    end

    def process!(source)
      process(source).tap { |response| raise SyntaxError unless response }
    end

    def self.enable!
      Preval.visitors << new
    end
  end
end
