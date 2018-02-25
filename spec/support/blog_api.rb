module BlogApi
  class Resource < Pragma::Client::Resource
    self.root_url = 'http://localhost:5000/api/v1'
  end

  class Article < Resource
    self.base_path = '/articles'
  end
end
