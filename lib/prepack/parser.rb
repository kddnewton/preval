# frozen_string_literal: true

module Prepack
  class Parser < Ripper::SexpBuilder
    def self.parse(source)
      new(source).parse
    end

    private

    SCANNER_EVENTS.each do |event|
      define_method(:"on_#{event}") do |token|
        Node.new(:"@#{event}", token, true)
      end
    end

    PARSER_EVENTS.each do |event|
      define_method(:"on_#{event}") do |*args|
        Node.new(event, args)
      end
    end
  end
end
