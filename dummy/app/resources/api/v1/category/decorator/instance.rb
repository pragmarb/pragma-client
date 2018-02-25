module API
  module V1
    module Category
      module Decorator
        class Instance < Pragma::Decorator::Base
          feature Pragma::Decorator::Type
          feature Pragma::Decorator::Association
          feature Pragma::Decorator::Timestamp

          property :id
          property :name
          timestamp :created_at
          timestamp :updated_at
        end
      end
    end
  end
end
