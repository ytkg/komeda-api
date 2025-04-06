# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'faraday'
require 'komeda'
require_relative './usecases/root_usecase'
require_relative './lib/todoist/client'

class App < Sinatra::Application
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  not_found do
    json({ error: 'Not found' })
  end

  get '/' do
    result = RootUsecase.execute

    json(result)
  end

  get '/:category' do
    raise Sinatra::NotFound unless Komeda.respond_to?(params[:category])

    json(Komeda.send(params[:category]))
  end
end
