module Slacks
  class V1 < Grape::API
    # /v1/slack
    resource 'slack' do
      resource 'thxes' do
        # POST /v1/slacks/thxes
        desc 'ポイントの確認'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post '/' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          {
            text: "ポイント残高: #{user.thx_balance} \n みんなからもらったポイント: #{user.received_thx}"
          }
        end

        # POST /v1/slacks/thxes
        desc 'ポイントの確認'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post '/' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          {
            text: "ポイント残高: #{user.thx_balance} \n みんなからもらったポイント: #{user.received_thx}"
          }
        end

        # POST /v1/slack/thxes/send
        desc 'ポイントの送信'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
          requires :text, type: String, desc: 'コマンド引数'
        end
        post 'send' do
          st_params = strong_params(params).permit(:team_id, :user_id, :text)
          if /@(?<receiver_id>.+)\|.+[\s　](?<thx>\d+)[\s　](?<comment>.+)/ =~ st_params[:text]
            receiver = User.find_by!(slack_user_id: receiver_id, slack_team_id: st_params[:team_id])
            sender = User.find_by!(slack_user_id: st_params[:user_id], slack_team_id: st_params[:team_id])
            if sender == receiver
              {
                text: '自分自身にポイントを送ることは出来ません><'
              }
            else
              ApplicationRecord.transaction do
                thx_transaction = ThxTransaction.new(thx_hash: SecureRandom.hex,
                                                     sender: sender,
                                                     receiver: receiver,
                                                     thx: thx.to_i,
                                                     comment: comment)
                sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
                receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
                thx_transaction.save!
              end
              {
                response_type: 'in_channel',
                text: "#{sender.name}さんが#{receiver.name}さんに#{thx}ポイントを送りました！:tada:",
                attachments: [
                  {
                    text: comment
                  }
                ]
              }
            end
          else
            {
              text: 'ポイントを送るには以下のようにコマンドを入力してください。',
              attachments: [
                {
                  text: '/thx @送る相手 ポイント メッセージ'
                }
              ]
            }
          end
        end
      end

      resource 'user' do
        # POST /v1/slacks/thxes
        desc 'ユーザーの追加'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'add' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          if user.present?
            {
              text: "#{user.name}はすでに登録されています"
            }
          else
            res = Net::HTTP.get(URI.parse("https://slack.com/api/users.info?token=#{ENV['SLACK_TOKEN']}&user=#{st_params[:user_id]}&pretty=1"))
            pretty_res = JSON.parse(res)
            ApplicationRecord::transaction do
              user = User.new(name: pretty_res['name'],
                              email: pretty_res['profile']['email'],
                              slack_user_id: pretty_res['id'],
                              slack_team_id: pretty_res['team_id'],
                              address: SecureRandom.hex,
                              thx_balance: User::INIT_THX,
                              password: User::SLACK_USER_DUMMY_PASSWORD,
                              password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                              verified: true)
              user.save!
            end
            {
              text: "pretty_res['name']さん、thxへようこそ! :tada:"
            }
          end
        end
      end
    end
  end
end