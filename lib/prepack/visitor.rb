# frozen_string_literal: true

module Prepack
  class Visitor
    def process(source)
      sexp = Parser.parse(source)
      sexp.tap { |node| node.visit(self) }.to_source if sexp
    end

    def process!(source)
      process(source).tap { |response| raise SyntaxError unless response }
    end

    def self.enable!
      Prepack.visitors << new
    end
  end
end
