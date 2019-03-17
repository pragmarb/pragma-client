# Pragma::Client

[![Build Status](https://travis-ci.org/pragmarb/pragma-client.svg?branch=master)](https://travis-ci.org/pragmarb/pragma-client)
[![Coverage Status](https://coveralls.io/repos/github/pragmarb/pragma-client/badge.svg?branch=master)](https://coveralls.io/github/pragmarb/pragma-client?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/986b54b1951aef56ce0e/maintainability)](https://codeclimate.com/github/pragmarb/pragma-client/maintainability)

Welcome to Pragma::Client, a gem for implementing clients for Pragma-based APIs.

The clients you can build with this gem are very similar to [Stripe's Ruby client](https://github.com/stripe/stripe-ruby)
in features and behavior.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pragma-client'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install pragma-client
```

## Usage

### Configuring clients

First of all, you should define your base resource class:

```ruby
module BlogService
  class Resource < Pragma::Client::Resource
    # Define the root URL of the API.
    self.root_url = 'https://www.example.com/api/v1'
    
    # Define authentication logic.
    authenticate_with do |request|
      request.query_params[:api_key] = '...'
      # or maybe:
      request.headers['Authorization'] = 'Bearer ...' 
    end
  end
end
```

Now, you can start creating API resources:

```ruby
module BlogService
  class Category < Resource
    # Optional: This will be inferred if not provided.
    self.base_url = '/categories'
    
    # This assumes you have a `by_category` filter on /articles.
    has_many :articles
  end
  
  class Article < Resource
    belongs_to :category
  end
end
```

### Using clients

Here are some usage examples:

```ruby
# Retrieve a category:
category = BlogService::Category.retrieve('test-category')

# Retrieve the articles of the category. This will loop through all the pages:
category.articles.each do |article|
  puts article.title
end

# Create a new article in the category:
category.articles.create(
  title: 'New Article', 
  body: 'This is the body of my article',
) 
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pragmarb/pragma-client. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pragma::Client project’s codebases, issue trackers, chat rooms and 
mailing lists is expected to follow the [code of conduct](https://github.com/pragmarb/pragma-client/blob/master/CODE_OF_CONDUCT.md).
