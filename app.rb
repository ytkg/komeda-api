# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'komeda'
require_relative './usecases/root_usecase'

def cache
  return unless block_given?

  $cache ||= {}
  key = Time.now.strftime('%Y%d%m%H%M')

  $cache[key] ||= yield
end

class App < Sinatra::Application
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  not_found do
    json({ error: 'Not found' })
  end

  get '/' do
    result = cache { RootUsecase.execute }

    json(result)
  end

  get '/:category' do
    raise Sinatra::NotFound unless Komeda.respond_to?(params[:category])

    json(Komeda.send(params[:category]))
  end
end
