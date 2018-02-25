module API
  module V1
    module Article
      module Contract
        class Base < Pragma::Contract::Base
          property :category
          property :title, type: coercible(:string)

          validation do
            required(:category).filled
            required(:title).filled
          end

          def category=(val)
            super ::Category.find_by(id: val)
          end
        end
      end
    end
  end
end
