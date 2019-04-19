# frozen_string_literal: true

module Preval
  class Visitor
    def self.enable!
      Preval.visitors << new
    end
  end
end
