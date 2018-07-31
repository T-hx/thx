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
          if user
            {
              text: "ポイント残高: #{user.thx_balance} \n みんなからもらったポイント: #{user.received_thx}"
            }
          else
            {
              text: "Not yet registered.:ghost:\nYou can register with this command.\n ```/thx_register``` "
            }
          end
        end

        # POST /v1/slack/thxes/comment
        desc 'show comments'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'comment' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          if user
            thxes = ThxTransaction.where(receiver: user).limit(20)
            text = thxes.map {|thx| "#{thx.thx} thx from #{thx.sender&.name}\n#{thx.comment}"}.join("\n\n")
            {
              text: "*Good job.* :coffee: \n*Thx Comments List. total #{thxes.count}*\n#{text}"
            }
          else
            {
              text: "Not yet registered.:ghost:\nYou can register with this command.\n ```/thx_register``` "
            }
          end
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
            receiver = User.find_by(slack_user_id: receiver_id, slack_team_id: st_params[:team_id])
            sender = User.find_by(slack_user_id: st_params[:user_id], slack_team_id: st_params[:team_id])
            if sender.nil?
              {
                text: "Not yet registered.:ghost:\nYou can register with this command.\n ```/thx_register``` "
              }
            elsif receiver.nil?
              {
                text: "the reciever hasn't joined to the thx system yet.\nLet's invite the person!:handshake:"
              }
            elsif sender == receiver
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

        # POST /v1/slacks/thxes/help
        desc 'thxのhelp'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'help' do
          {
            "text": "Would you like to play a game?",
            "attachments": [
              {
                "text": "Choose a game to play",
                "fallback": "You are unable to choose a game",
                "callback_id": "wopr_game",
                "color": "#3AA3E3",
                "attachment_type": "default",
                "actions": [
                  {
                    "name": "game",
                    "text": "Chess",
                    "type": "button",
                    "value": "chess"
                  },
                  {
                    "name": "game",
                    "text": "Falken's Maze",
                    "type": "button",
                    "value": "maze"
                  },
                  {
                    "name": "game",
                    "text": "Thermonuclear War",
                    "style": "danger",
                    "type": "button",
                    "value": "war",
                    "confirm": {
                      "title": "Are you sure?",
                      "text": "Wouldn't you prefer a good game of chess?",
                      "ok_text": "Yes",
                      "dismiss_text": "No"
                    }
                  }
                ]
              }
            ]
          }
        end

        # POST /v1/slacks/thxes/stamp
        desc 'ボタンが押された時'
        post 'stamp' do
          st_params = strong_params(params)
          {
            text: "#{st_params[:payload]}"
          }
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
              text: "#{user.name}, Already registered:ok:\nhow to use:eyes: ```/thx_help``` "
            }
          else
            res = Net::HTTP.get(URI.parse("https://slack.com/api/users.info?token=#{ENV['SLACK_TOKEN']}&user=#{st_params[:user_id]}&pretty=1"))
            pretty_res = JSON.parse(res)
            res_user = pretty_res['user']
            ApplicationRecord::transaction do
              user = User.new(name: res_user['name'],
                              email: res_user['profile']['email'],
                              slack_user_id: res_user['id'],
                              slack_team_id: res_user['team_id'],
                              address: SecureRandom.hex,
                              thx_balance: User::INIT_THX,
                              password: User::SLACK_USER_DUMMY_PASSWORD,
                              password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                              verified: true)
              user.save!
            end

            {
              text: "#{res_user['name']}, Welcome to thx! :wave: \nThis system is for Peer-To-Peer Bonus.\nhow to use:eyes: ```/thx_help``` "
            }
          end
        end
      end
    end
  end
end