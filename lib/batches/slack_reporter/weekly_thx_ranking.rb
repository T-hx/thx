module Batches
  module SlackReporter
    class WeeklyThxRanking < Base
      extend RankingMessageBase

      def self.start_date
        Time.current.yesterday.beginning_of_week
      end

      def self.end_date
        Time.current.yesterday.end_of_week
      end

      def self.build_message
        {
          "text": "*Thx Weekly Ranking (#{start_date.to_date}~#{end_date.to_date})* :tada:",
          "attachments": [
            {
              "color": "good",
              "title": "受信回数ランキング :inbox_tray: =======\n",
              "title_link": "https://api.slack.com/",
              "text": build_received_count_ranking(start_date, end_date)
            },
            {
              "color": "good",
              "title": "送信回数ランキング :inbox_tray: =======\n",
              "title_link": "https://api.slack.com/",
              "text": build_sent_count_ranking(start_date, end_date)
            },
            {
              "color": "good",
              "title": "thx獲得量ランキング :inbox_tray: =======\n",
              "title_link": "https://api.slack.com/",
              "text": build_thx_amount_ranking(start_date, end_date)
            }
          ]
        }
      end
    end
  end
end
