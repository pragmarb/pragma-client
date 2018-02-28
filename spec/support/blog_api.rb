module BlogApi
  class Resource < Pragma::Client::Resource
    self.root_url = 'http://localhost:5000/api/v1'
  end

  class Category < Resource
    self.base_path = '/categories'
    has_many :articles
  end

  class Article < Resource
    self.base_path = '/articles'
    belongs_to :category
  end
end
