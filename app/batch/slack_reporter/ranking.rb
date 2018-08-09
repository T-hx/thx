module SlackReport
  class WeeklyThxRanking < Base
    def self.build_message
      @logger.info '[start] start thx weekly ranking'
      # st = Date.yesterday.beginning_of_week
      # en = Date.yesterday.end_of_week
      # text = "*Thx Weekly Ranking (#{st}~#{en})* :tada:\n" +
      #   build_received_count_ranking(st, en) + "\n" +
      #   build_sent_count_ranking(st, en) + "\n" +
      #   build_thx_amount_ranking(st, en) + "\n"
      "weekly ranking"
      @logger.info '[end] end thx weekly ranking'
    end
  end

  class MonthlyThxRanking < Base
    def self.build_message
      @logger.info '[start] start thx monthly ranking'
      # st = Date.yesterday.beginning_of_week
      # en = Date.yesterday.end_of_week
      # text = "*Thx Monthly Ranking (#{st}~#{en})* :tada:\n" +
      #   build_received_count_ranking(st, en) + "\n" +
      #   build_sent_count_ranking(st, en) + "\n" +
      #   build_thx_amount_ranking(st, en) + "\n"
      "monthly ranking"
      @logger.info '[end] end thx monthly ranking'
    end
  end
end

