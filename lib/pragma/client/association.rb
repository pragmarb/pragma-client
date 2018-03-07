# frozen_string_literal: true

module Pragma
  module Client
    class Association
      attr_reader :resource_klass, :type, :property

      def initialize(resource_klass, type, property)
        @resource_klass = resource_klass
        @type = type
        @property = property
      end

      def association_name
        "#{resource_klass}.#{property}"
      end

      def belongs_to?
        type == :belongs_to
      end

      def has_many?
        type == :has_many
      end

      def filter_name
        case type
        when :has_many
          "by_#{resource_klass.name.demodulize.underscore}".to_sym
        else
          fail NotImplementedError, "Association#filter_name is not implemented for :#{type}!"
        end
      end

      def parent_property
        case type
        when :has_many
          resource_klass.name.demodulize.underscore.to_sym
        else
          fail NotImplementedError, "Association#parent_property is not implemented for :#{type}!"
        end
      end

      def associated_resource_klass
        return @associated_resource_klass if @associated_resource_klass

        namespace = resource_klass.name.to_s.split('::')[0..-2]
        class_name = (has_many? ? property.to_s.singularize : property.to_s).classify

        @associated_resource_klass = (namespace << class_name).join('::')
      end

      def load(resource)
        check_associated_resource_klass

        case type
        when :belongs_to
          load_belongs_to(resource)
        when :has_many
          load_has_many(resource)
        else
          fail NotImplementedError, "Association#load is not implemented for :#{type}!"
        end
      end

      private

      def check_associated_resource_klass
        return if associated_resource_klass.safe_constantize

        fail <<~TXT.delete("\n").strip
          Expected association #{association_name} to correspond to #{associated_resource_klass},
          but the class could not be found!
        TXT
      end

      def load_belongs_to(resource)
        value = resource.to_h[property.to_s]

        if value.is_a?(Hash)
          associated_resource_klass.new(value)
        else
          associated_resource_klass.safe_constantize.retrieve(value)
        end
      end

      def load_has_many(resource)
        AssociationProxy.new(resource, self)
      end
    end
  end
end
