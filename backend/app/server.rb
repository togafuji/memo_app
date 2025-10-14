# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'rack/cors'

module MemoApp
  class Server < Sinatra::Base
    use Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post options]
      end
    end

    configure do
      set :show_exceptions, false
      set :server_settings, timeout: 25
    end

    before do
      headers 'Access-Control-Allow-Origin' => '*'
    end

    options '/graphql' do
      headers 'Access-Control-Allow-Headers' => 'Content-Type'
      204
    end

    post '/graphql' do
      content_type :json
      payload = JSON.parse(request.body.read)
      result = MemoApp::GraphQL::Schema.execute(
        payload['query'],
        variables: payload['variables'] || {},
        operation_name: payload['operationName'],
        context: {}
      )
      JSON.dump(result)
    rescue JSON::ParserError => e
      status 400
      JSON.dump({ errors: [{ message: e.message }] })
    end

    get '/graphql/subscriptions' do
      note_id = params['noteId']
      halt 400, 'noteId is required' if note_id.nil? || note_id.empty?

      content_type 'text/event-stream'
      stream :keep_open do |out|
        subscription_id = MemoApp::GraphQL::Schema.subscriptions.subscribe(
          'summaryUpdated',
          { note_id: note_id },
          {},
          lambda do |result|
            payload = result.respond_to?(:to_h) ? result.to_h : result
            out << "data: #{JSON.dump(payload)}\n\n"
          end
        )

        out.callback do
          MemoApp::GraphQL::Schema.subscriptions.delete_subscription(subscription_id)
        end
      end
    end

    error do
      content_type :json
      status 500
      JSON.dump({ errors: [{ message: env['sinatra.error']&.message || 'Internal Server Error' }] })
    end
  end
end
