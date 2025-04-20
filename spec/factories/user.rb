FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "indra #{n}" }
    password { 'sekrit' }
  end
end
