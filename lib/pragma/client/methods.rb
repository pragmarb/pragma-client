# frozen_string_literal: true

module Pragma
  module Client
    module Methods
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def all(params: {}, headers: {})
          Enumerator.new do |yielder|
            page = 1

            loop do
              response = RestClient::Request.execute(
                method: :get,
                url: build_resource_url,
                headers: build_headers(
                  user_headers: headers,
                  params: params.merge(page_param => page)
                )
              )

              parsed_response = JSON.parse(response.body)
              parsed_response['data'].map { |item| yielder << new(item) }

              page = parsed_response['next_page'] || fail(StopIteration)
            end
          end.lazy
        end

        def retrieve(id, params: {}, headers: {})
          response = RestClient::Request.execute(
            method: :get,
            url: build_resource_url(id),
            headers: build_headers(
              user_headers: headers,
              params: params
            )
          )

          new(JSON.parse(response.body))
        end

        def create(entity, params: {}, headers: {})
          response = RestClient::Request.execute(
            method: :post,
            url: build_resource_url,
            headers: build_headers(
              client_headers: { content_type: 'application/json' },
              user_headers: headers,
              params: params
            ),
            payload: entity.to_json
          )

          new(JSON.parse(response.body))
        end

        def patch(id, entity, params: {}, headers: {})
          response = RestClient::Request.execute(
            method: :patch,
            url: build_resource_url(id),
            headers: build_headers(
              client_headers: { content_type: 'application/json' },
              user_headers: headers,
              params: params
            ),
            payload: entity.to_json
          )

          new(JSON.parse(response.body))
        end

        def delete(id, params: {}, headers: {})
          RestClient::Request.execute(
            method: :delete,
            url: build_resource_url(id),
            headers: build_headers(
              user_headers: headers,
              params: params
            )
          )
        end

        private

        def build_resource_url(*fragments)
          all_fragments = [root_url] + [base_path] + fragments
          all_fragments.map { |part| part.to_s.delete_prefix('/').delete_suffix('/') }.join('/')
        end

        def default_headers
          {
            accept: 'application/json'
          }
        end

        def build_headers(client_headers: {}, user_headers: {}, params: {})
          default_headers.merge(client_headers).merge(user_headers).merge(params: params)
        end
      end
    end
  end
end
