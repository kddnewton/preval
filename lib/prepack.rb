require 'prepack/version'

module Prepack
  class << self
    attr_accessor :passes

    def process(source)
      passes.each do |pass|
        source = pass.process(source)
      end
      source
    end
  end

  self.passes = []
end
