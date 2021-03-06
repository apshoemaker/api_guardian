FactoryGirl.define do
  factory :identity, class: ApiGuardian::Identity do |f|
    f.sequence(:provider) { |n| "#{Faker::Lorem.word} #{n}" }
    f.sequence(:provider_uid) { |n| "#{Faker::Bitcoin.address} #{n}" }
    f.tokens { { token: SecureRandom.hex(32) } }
    association :user, factory: :user
  end
end
