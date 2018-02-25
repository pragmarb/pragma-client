FactoryBot.define do
  factory :article do
    category
    sequence(:title) { |n| "Article #{n}" }
    body { Faker::Lorem.paragraph }
  end
end
