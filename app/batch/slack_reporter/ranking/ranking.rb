module SlackReport
  class WeeklyThxRanking < Base
    extend MessageBuilder

    START_DATE = Date.yesterday.beginning_of_week
    END_DATE = Date.yesterday.end_of_week
    
    def self.build_message
      "*Thx Weekly Ranking (#{START_DATE}~#{END_DATE})* :tada:\n" +
        build_received_count_ranking(START_DATE, END_DATE) + "\n" +
        build_sent_count_ranking(START_DATE, END_DATE) + "\n" +
        build_thx_amount_ranking(START_DATE, END_DATE) + "\n"
    end
  end

  class MonthlyThxRanking < Base
    extend MessageBuilder
    
    START_DATE = Date.yesterday.beginning_of_month
    END_DATE = Date.yesterday.end_of_month
    
    def self.build_message
      "*Thx Monthly Ranking (#{START_DATE}~#{END_DATE})* :tada:\n" +
        build_received_count_ranking(START_DATE, END_DATE) + "\n" +
        build_sent_count_ranking(START_DATE, END_DATE) + "\n" +
        build_thx_amount_ranking(START_DATE, END_DATE) + "\n"
    end
  end
end

