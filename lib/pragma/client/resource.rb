# frozen_string_literal: true

module Pragma
  module Client
    # Represents a resource in your API, exposing an interface to retrieve and manipulate the
    # instances of that resource.
    #
    # @abstract Subclass and set {#root_url} and {#base_path} to create a new resource. To avoid
    #   having to set {#root_url} every time, we recommend creating your own base +Resource+ class
    #   where you only set {#root_url}, then inherit from that class.
    class Resource
      include Methods

      class << self
        # @!attribute [rw] root_url
        #   @return [String] The API's root URL (e.g. http://example.com/api/v1).
        #
        # @!attribute [rw] base_path
        #   @return [String] The resource's base path (e.g. /articles). The default is inferred
        #     from the name of the class.
        #
        # @!attribute [rw] page_param
        #   @return [Symbol|String] The parameter to use to specify the page number. The default
        #     is +:page+.
        #
        # @!attribute [rw] per_page_param
        #   @return [Symbol|String] The parameter to use to specify the number of items per page.
        #     The default is +:per_page+.
        attr_writer :root_url, :base_path, :page_param, :per_page_param

        def root_url
          @root_url ||= superclass.root_url if superclass.respond_to?(:root_url)
        end

        def base_path
          @base_path ||= "/#{self.class.name.demodulize.underscore.pluralize}"
        end

        def page_param
          @page_param ||= :page
        end

        def per_page_param
          @per_page_param ||= :per_page
        end
      end

      # Initializes the resource, optionally pre-loading data.
      #
      # Note that the data of the resource is not validated against any schemas, as client's
      # don't have access to the schema of the resource.
      #
      # @param [Hash] data data to preload
      def initialize(data = {})
        @data = data
      end

      # Converts the resource to a hsah by returning the data.
      #
      # @return [Hash] the data
      def to_h
        @data
      end

      # Deletes the resource by issuing a +DELETE+ request.
      #
      # @param [Hash] params any params to pass
      # @param [Hash] headers any headers to pass
      #
      # @return [TrueClass]
      def delete(params: {}, headers: {})
        self.class.delete(id, params: params, headers: headers)
        true
      end

      # Reloads the resource by issuing a +GET+ request and resetting the data.
      #
      # @param [Hash] params any params to pass
      # @param [Hash] headers any headers to pass
      #
      # @return [Resource] the resource
      def reload(params: {}, headers: {})
        @data = self.class.retrieve(id, params: params, headers: headers).to_h
        self
      end

      # Saves the resource.
      #
      # If the resource has been persisted (which is determined by checking whether the +id+
      # property is present), issues a +PATCH+ request to update the existing resource, otherwise
      # issues a +POST+ request to create a new instance.
      #
      # When the request completes, the resource's data will be updated with what is returned by
      # the API, so that the ID and any other properties are set.
      #
      # @param [Hash] params any params to pass
      # @param [Hash] headers any headers to pass
      #
      # @return [Resource] the resource
      def save(params: {}, headers: {})
        new_resource = if id
          self.class.patch(id, @data, params: params, headers: headers)
        else
          self.class.create(@data, params: params, headers: headers)
        end

        @data = new_resource.to_h

        self
      end

      # Updates the resource.
      #
      # First applies the provided diff to the data, then saves the resource by calling {#save}.
      #
      # @see #save
      def update(diff, params: {}, headers: {})
        @data = @data.merge(diff)
        save(params: params, headers: headers)

        self
      end

      # Handles calls to missing method by treating them as setters when the method ends with an
      # equal sign and as getters when the method doesn't.
      #
      # After the missing method is called, it's also defined so that {#missing_method} is not
      # called again, thus improving performance.
      #
      # Note that this behavior means that a Resource instance will never raise a +NoMethodError+,
      # but rather will return +nil+.
      #
      # @param [Symbol] method the name of the missing method
      # @param [Array] args the arguments to pass to the method
      #
      # @return [Object] what the method returns
      def method_missing(method, *args) # rubocop:disable Style/MethodMissing
        method = method.to_s

        if method.end_with?('=')
          self.class.class_eval do
            define_method(method) do |val|
              @data[method.delete_suffix('=')] = val
            end
          end
        else
          self.class.class_eval do
            define_method(method) do
              @data[method]
            end
          end
        end

        send(method, *args, &block)
      end

      # Returns whether the object responds to the given method.
      #
      # Since we always respond to missing methods, this always returns +true+.
      #
      # @param [Symbol] _method the method being checked
      # @param [Boolean] _include_private whether to look in private methods
      #
      # @return [TrueClass]
      #
      # @see #method_missing
      def respond_to_missing?(_method, _include_private = false)
        true
      end
    end
  end
end
