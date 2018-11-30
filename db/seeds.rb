# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
10.times do |i|
User.create(name: "test#{i}",
         email: "test#{i}@gmail.com",
         slack_user_id: "test#{i}",
         slack_team_id: 'abc',
         address: SecureRandom.hex,
         thx_balance: User::INIT_THX,
         password: User::SLACK_USER_DUMMY_PASSWORD,
         password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
         verified: true)
end

50.times do |i|
  sender_id = nil
  receiver_id = nil
  while sender_id == receiver_id do
    sender_id = "test#{rand(0..9)}"
    receiver_id = "test#{rand(0..9)}"
  end
  team_id = 'abc'
  sender = User.find_by(slack_user_id: sender_id, slack_team_id: team_id)
  receiver = User.find_by(slack_user_id: receiver_id, slack_team_id: team_id)
  thx = rand(10..20)
  comment = ["いつもありがとうございます", "感謝します", "これからも宜しくお願いします", "Thank you!"].sample
  thx_transaction = ThxTransaction.create(thx_hash: SecureRandom.hex,
                        sender: sender,
                        receiver: receiver,
                        thx: thx.to_i,
                        comment: comment)
  sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
  receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
  thx_transaction.save!
end
