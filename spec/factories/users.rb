FactoryBot.define do
  factory :user do
    sequence(:email){|i| "example#{i}@example.com" }
    password 'pass-word000'
    sequence(:name){|i| "user#{i}"}
    address { SecureRandom.hex }
    thx_balance 1000
    sequence(:received_thx){|i| i*100}
    sequence(:slack_user_id){|i| "#{i}"}
    sequence(:slack_team_id){|i| 'a' }
  end
end