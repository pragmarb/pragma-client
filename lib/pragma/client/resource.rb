# frozen_string_literal: true

module Pragma
  module Client
    class Resource
      include Methods

      class << self
        attr_writer :root_url, :base_path, :page_param, :per_page_param

        def base_path
          @base_path ||= "/#{self.class.name.demodulize.underscore.pluralize}"
        end

        def root_url
          @root_url ||= superclass.root_url if superclass.respond_to?(:root_url)
        end

        def page_param
          @page_param ||= :page
        end

        def per_page_param
          @per_page_param ||= :per_page
        end
      end

      def initialize(data = {})
        @data = data
      end

      def to_h
        @data
      end

      def delete(params: {}, headers: {})
        self.class.delete(id, params: params, headers: headers)
      end

      def reload(params: {}, headers: {})
        @data = self.class.retrieve(id, params: params, headers: headers).to_h
      end

      def save(params: {}, headers: {})
        new_resource = if id
          self.class.patch(id, @data, params: params, headers: headers)
        else
          self.class.create(@data, params: params, headers: headers)
        end

        @data = new_resource.to_h
      end

      def update(diff, params: {}, headers: {})
        @data = @data.merge(diff)
        save(params: params, headers: headers)
      end

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

      def respond_to_missing?(_method, _include_private = false)
        true
      end
    end
  end
end
