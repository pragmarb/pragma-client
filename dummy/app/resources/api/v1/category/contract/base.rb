module API
  module V1
    module Category
      module Contract
        class Base < Pragma::Contract::Base
          property :name, type: coercible(:string)

          validation do
            required(:name).filled
          end
        end
      end
    end
  end
end
