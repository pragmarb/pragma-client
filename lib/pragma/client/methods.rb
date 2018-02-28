# frozen_string_literal: true

module Pragma
  module Client
    # Provides the HTTP methods to interact with resources in a "static" manner. Some of these
    # methods are exposed and used in the Resource class, while others are used internally to
    # provide higher-level abstractions.
    module Methods
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        # Returns an enumerator looping through all the resources.
        #
        # The enumerator will loop through all the pages until the end.
        #
        # @param [Hash] params params to forward to the API
        # @param [Hash] headers headers to forward to the API
        #
        # @return [Enumerator] an enumerator yielding instances of the resource
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

        # Retrieves an instance of this resource by ID.
        #
        # @param [String|Integer] id the ID of the resource to retrieve
        # @param [Hash] params params to forward to the API
        # @param [Hash] headers headers to forward to the API
        #
        # @return [Resource] the retrieved resource
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

        # Creates an instance of the resource.
        #
        # Note that the resource that is returned is built with the payload that the server
        # responds with, so that the ID of the resource and any other properties are loaded
        # correctly.
        #
        # @param [Hash] entity the body of the entity
        # @param [Hash] params params to forward to the API
        # @param [Hash] headers headers to forward to the API
        #
        # @return [Resource] the newly created resource
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

        # Patches an instance of the resource.
        #
        # Note that the resource that is returned is built with the payload that the server
        # responds with, so that any properties computed by the server are loaded correctly.
        #
        #
        # @param [String|Integer] id the ID of the resource to patch
        # @param [Hash] diff the patch to apply to the resource
        # @param [Hash] params params to forward to the API
        # @param [Hash] headers headers to forward to the API
        #
        # @return [Resource] the newly created resource
        def patch(id, diff, params: {}, headers: {})
          response = RestClient::Request.execute(
            method: :patch,
            url: build_resource_url(id),
            headers: build_headers(
              client_headers: { content_type: 'application/json' },
              user_headers: headers,
              params: params
            ),
            payload: diff.to_json
          )

          new(JSON.parse(response.body))
        end

        # Deletes an instance of the resource by ID.
        #
        # @param [String|Integer] id the ID of the resource to patch
        # @param [Hash] params params to forward to the API
        # @param [Hash] headers headers to forward to the API
        def delete(id, params: {}, headers: {})
          RestClient::Request.execute(
            method: :delete,
            url: build_resource_url(id),
            headers: build_headers(
              user_headers: headers,
              params: params
            )
          )

          nil
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
