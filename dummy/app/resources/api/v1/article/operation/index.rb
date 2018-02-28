module API
  module V1
    module Article
      module Operation
        class Index < Pragma::Operation::Index
          self['filtering.filters'] = [
            Pragma::Filter::Equals.new(param: :by_category, column: :category_id)
          ]
        end
      end
    end
  end
end
