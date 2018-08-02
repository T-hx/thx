class WeeklyThxRanking
  include Batch
  extend MessageBuilder

  def self.execute
    @logger.info '[start] start thx weekly ranking'
    st = Date.yesterday.beginning_of_week
    en = Date.yesterday.end_of_week
    text = "*Thx Weekly Ranking (#{st}~#{en})* :tada:\n" +
      build_received_count_ranking(st, en) + "\n" +
      build_sent_count_ranking(st, en) + "\n" +
      build_thx_amount_ranking(st, en) + "\n"
    notifier = Slack::Notifier.new("https://hooks.slack.com/services/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")
    notifier.ping(text)
    @logger.info '[end] end thx weekly ranking'
  end
end
