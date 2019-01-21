# frozen_string_literal: true

module Prepack
  class Parser < Ripper::SexpBuilder
    private

    SCANNER_EVENTS.each do |event|
      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(token)
          Node.new(:@#{event}, token, true)
        end
      End
    end

    events = private_instance_methods(false).grep(/\Aon_/) { $'.to_sym }
    (PARSER_EVENTS - events).each do |event|
      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(*args)
          Node.new(:#{event}, args)
        end
      End
    end
  end
end
