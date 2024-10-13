# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'komeda'

class App < Sinatra::Application
  not_found do
    json({ error: 'Not found' })
  end

  get '/:category' do
    raise Sinatra::NotFound unless Komeda.respond_to?(params[:category])

    json(Komeda.send(params[:category]))
  end
end
