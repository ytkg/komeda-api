module Todoist
  class Client
    BASE_URL = 'https://api.todoist.com/'

    attr_reader :token

    def initialize(token)
      @conn = Faraday.new(url: BASE_URL) do |f|
        f.request :authorization, 'Bearer', token
        f.response :json, parser_options: { symbolize_names: true }
        f.adapter Faraday.default_adapter
      end
    end

    def get(endpoint, params = {})
      response = @conn.get(endpoint, params)
      handle_response(response)
    end

    def post(endpoint, body = {})
      response = @conn.post(endpoint) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.success?
        response.body
      else
        { error: response.status, message: response.body }
      end
    rescue JSON::ParserError
      { error: 'Invalid JSON response', message: response.body }
    end
  end
end
