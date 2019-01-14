FactoryBot.define do
  factory :thx_transaction do
    thx_hash { SecureRandom.hex }
    sender nil
    receiver nil
    thx 100
    comment { ["いつもありがとうございます", "感謝します", "これからも宜しくお願いします", "Thank you!"].sample }
    created_at Time.current.yesterday
  end
end
