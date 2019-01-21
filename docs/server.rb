# frozen_string_literal: true

require 'bundler/setup'
require 'prepack'
require 'sinatra'

get '/' do
  send_file(File.expand_path('index.html', __dir__))
end

post '/' do
  Prepack.process(request.body.read).tap do |response|
    halt 422 unless response
  end
end
