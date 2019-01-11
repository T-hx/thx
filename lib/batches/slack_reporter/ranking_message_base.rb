module Batches
  module SlackReporter
    module RankingMessageBase

      MEDAL_STAMP = %w(:first_place_medal: :second_place_medal: :third_place_medal:)

      def build_received_count_ranking(st, en)
        best_3 = ThxTransaction.where(created_at: st..en).where.not(receiver: nil).
          group(:receiver).count.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }.take(3)
        best_3.map.with_index(1) do |data, index|
          "*Best#{index} #{MEDAL_STAMP[index - 1]}* \n *#{data.first.name}* \n受信回数 #{data.second}回 \n"
        end.join("\n")
      end

      def build_sent_count_ranking(st, en)
        best_3 = ThxTransaction.where(created_at: st..en).where.not(sender: nil).
          group(:sender).count.sort { |(k1, v1), (k2, v2)| v2 <=> v1 }.take(3)
        best_3.map.with_index(1) do |data, index|
          "*Best#{index} #{MEDAL_STAMP[index - 1]}* \n *#{data.first.name}* \n送信回数 #{data.second}回 \n"
        end.join("\n")
      end

      def build_thx_amount_ranking(st, en)
        best_3 = ThxTransaction.where(created_at: st..en).where.not(receiver: nil).
          group(:receiver).sum(:thx).sort { |(k1, v1), (k2, v2)| v2 <=> v1 }.take(3)
        best_3.map.with_index(1) do |data, index|
          "*Best#{index} #{MEDAL_STAMP[index - 1]}* \n *#{data.first.name}* \nthx獲得量 #{data.second}thx \n"
        end.join("\n")
      end
    end
  end
end