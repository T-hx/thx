module Ranking
  class WeekThxRanking
    include Batch
    class << self
      MEDAL_STAMP = %w(:first_place_medal: :second_place_medal: :third_place_medal:)
      def excute
        @logger.info '[start] start thx ranking on week'
        summary = ThxTransaction.where(created_at: Date.yesterday.beginning_of_week..Date.yesterday.end_of_week).
          where.not(receiver: nil).group(:receiver).count
        best_3 = summary.sort_by {|_user, count| count}.take(3)
        pretty_best_3 = best_3.map.with_index(1) {|data, index| "*best#{index} #{MEDAL_STAMP[index]}* \n *#{data.first.name}* \n#{data.second} count thx received \n"}
        text = pretty_best_3.unshift("receive count ranking, *last week!!!* \n").join("\n")
        notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.ping(text)
      end
    end
  end
end
