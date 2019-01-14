require 'rails_helper'

RSpec.describe Batches::SlackReporter::WeeklyThxRanking do
  describe 'build_message' do
    before do
      create(:thx_transaction, sender: slack_user1, receiver: slack_user3)
      create(:thx_transaction, sender: slack_user1, receiver: slack_user3)
      create(:thx_transaction, sender: slack_user1, receiver: slack_user3)
      create(:thx_transaction, sender: slack_user2, receiver: slack_user2)
      create(:thx_transaction, sender: slack_user2, receiver: slack_user2)
      create(:thx_transaction, sender: slack_user3, receiver: slack_user1)
    end
    let(:slack_user1) {FactoryBot.create(:user)}
    let(:slack_user2) {FactoryBot.create(:user)}
    let(:slack_user3) {FactoryBot.create(:user)}
    let(:start_date) {Time.current.yesterday.beginning_of_week}
    let(:end_date) {Time.current.yesterday.end_of_week}
    let(:message) {
      {
        "text": "*Thx Weekly Ranking (#{start_date.to_date}~#{end_date.to_date})* :tada:",
        "attachments": [
          {
            "color": "good",
            "title": "受信回数ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": "*Best1 :first_place_medal:* \n *#{slack_user3.name}* \n受信回数 3回 \n\n*Best2 :second_place_medal:* \n *#{slack_user2.name}* \n受信回数 2回 \n\n*Best3 :third_place_medal:* \n *#{slack_user1.name}* \n受信回数 1回 \n"
          },
          {
            "color": "good",
            "title": "送信回数ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": "*Best1 :first_place_medal:* \n *#{slack_user1.name}* \n送信回数 3回 \n\n*Best2 :second_place_medal:* \n *#{slack_user2.name}* \n送信回数 2回 \n\n*Best3 :third_place_medal:* \n *#{slack_user3.name}* \n送信回数 1回 \n"
          },
          {
            "color": "good",
            "title": "thx獲得量ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": "*Best1 :first_place_medal:* \n *#{slack_user3.name}* \nthx獲得量 300thx \n\n*Best2 :second_place_medal:* \n *#{slack_user2.name}* \nthx獲得量 200thx \n\n*Best3 :third_place_medal:* \n *#{slack_user1.name}* \nthx獲得量 100thx \n"
          }
        ]
      }
    }
    it '週間ランキングがフォーマットできること' do
      expect(Batches::SlackReporter::WeeklyThxRanking.build_message).to eq message
    end
  end
end
