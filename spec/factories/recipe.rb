FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe #{n}" }
  end
end
