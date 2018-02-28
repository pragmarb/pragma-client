# frozen_string_literal: true

module Pragma
  module Client
    class AssociationProxy
      include Enumerable

      attr_reader :resource, :association

      def initialize(resource, association)
        @resource = resource
        @association = association
      end

      def each(&block)
        all.each(&block)
      end

      def all(params: {}, headers: {})
        associated_resource_klass.all(
          params: params.merge(association.filter_name => resource.id),
          headers: headers
        )
      end

      def create(entity, params: {}, headers: {})
        associated_resource_klass.create(
          entity.merge(association.parent_property => resource.id),
          params: params,
          headers: headers
        )
      end

      private

      def associated_resource_klass
        @associated_resource_klass ||= association.associated_resource_klass.constantize
      end
    end
  end
end
