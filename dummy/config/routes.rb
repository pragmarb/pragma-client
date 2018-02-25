Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :articles, only: %i(index show create update destroy)
    end
  end
  namespace :api do
    namespace :v1 do
      resources :categories, only: %i(index show create update destroy)
    end
  end
  namespace :api do
    namespace :v1 do
      resources :pings, only: %i(create)
    end
  end
end
