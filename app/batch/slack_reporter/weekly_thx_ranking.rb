module SlackReporter
  class WeeklyThxRanking < Base
    extend RankingMessageBase

    START_DATE = Date.yesterday.beginning_of_week
    END_DATE = Date.yesterday.end_of_week

    def self.build_message
      {
        "text": "*Thx Weekly Ranking (#{START_DATE}~#{END_DATE})* :tada:",
        "attachments": [
          {
            "color": "good",
            "title": "受信回数ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": build_received_count_ranking(START_DATE, END_DATE)
          },
          {
            "color": "good",
            "title": "送信回数ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": build_sent_count_ranking(START_DATE, END_DATE)
          },
          {
            "color": "good",
            "title": "thx獲得量ランキング :inbox_tray: =======\n",
            "title_link": "https://api.slack.com/",
            "text": build_thx_amount_ranking(START_DATE, END_DATE)
          }
        ]
      }
    end
  end
end
