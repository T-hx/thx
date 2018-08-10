module Slacks
  class V1 < Grape::API
    # /v1/slack
    resource 'slack' do
      resource 'thxes' do
        # POST /v1/slacks/thxes
        desc 'thx残高の確認'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post '/', jbuilder: 'v1/slacks/me' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          @user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          not_registered unless @user
        end

        # POST /v1/slack/thxes/comment
        # TODO: コメントがnilのものは表示しない
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
            @text = thxes.map {|thx| "#{thx.thx} thx from #{thx.sender&.name}\n#{thx.comment}"}.join("\n\n")
          else
            {
              icon_emoji: ':thx:',
              attachments: [
                {
                  text: "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます",
                  color: 'danger',
                },
                {
                  fallback: "",
                  footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                }
              ]
            }
          end
        end

        # POST /v1/slack/thxes/send
        desc 'thxの送信'
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
            max_thx = sender.thx_balance
            if sender.nil?
              {
                icon_emoji: ':thx:',
                attachments: [
                  {
                    text: "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます",
                    color: 'danger'
                  },
                  {
                    fallback: "",
                    footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                  }
                ]
              }
            elsif receiver.nil?
              {
                icon_emoji: ':thx:',
                attachments: [
                  {
                    text: "#{receiver.name}はまだThxに参加してません。招待してください!:handshake:",
                    color: 'danger'
                  },
                  {
                    fallback: "",
                    footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                  }
                ]
              }
            elsif sender == receiver
              {
                icon_emoji: ':thx:',
                attachments: [
                  {
                    text: '自分自身にthxを送ることは出来ません><',
                    color: 'danger'
                  },
                  {
                    fallback: "",
                    footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                  }
                ]
              }
            elsif thx.to_i > max_thx
              {
                icon_emoji: ':thx:',
                attachments: [
                  {
                    text: "thxが不足しています。 あなたの残高: #{max_thx}thx",
                    color: 'danger'
                  },
                  {
                    fallback: "",
                    footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                  }
                ]
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
                icon_emoji: ':thx:',
                text: "#{sender.name}さんが#{receiver.name}さんに#{thx}thx送りました！:tada:",
                response_type: 'in_channel',
                attachments: [
                  {
                    text: comment,
                    color: 'good',
                  },
                  {
                    fallback: "",
                    footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                  }
                ]
              }
            end
          else
            {
              icon_emoji: ':thx:',
              attachments: [
                {
                  text: "ポイントを送るには以下のようにコマンドを入力してください。\n\"/thx @送る相手 ポイント メッセージ\"",
                  color: 'danger'
                },
                {
                  fallback: "",
                  footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
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
            icon_emoji: ":thx:",
            attachments: [
              {
                text: "このコマンドはまだ開発中です:man-bowing::skin-tone-3:",
                color: 'danger'
              },
              {
                fallback: "",
                footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
              }
            ]
          }
        end

        # POST /v1/slacks/thxes/stamp
        # TODO: 自分で送れないようにする
        # TODO: アクティブユーザーが増えたら実装する
        # TODO: リファクタ
        desc '追thx送信'
        post 'stamp' do
          st_params = strong_params(params)
          payload = JSON.parse(st_params[:payload])
          s_id = payload['actions'][0]['value'].split(' ')[1]
          thx = payload['actions'][0]['value'].split(' ')[0]
          receiver = User.find_by(slack_user_id: s_id, slack_team_id: payload['team']['id'])
          sender = User.find_by(slack_user_id: payload['user']['id'], slack_team_id: payload['team']['id'])
          max_thx = sender.thx_balance
          if sender.nil?
            {
              text: "Not yet registered.:ghost:\nYou can register with this command.\n ```/thx_register``` ",
              response_type: "ephemeral",
              replace_original: false
            }
          elsif receiver.nil?
            {
              text: "the reciever hasn't joined to the thx system yet.\nLet's invite the person!:handshake:",
              response_type: "ephemeral",
              replace_original: false
            }
          elsif sender == receiver
            {
              text: '自分自身にポイントを送ることは出来ません><',
              response_type: "ephemeral",
              replace_original: false
            }
          elsif thx.to_i > max_thx
            {
              text: "thxが不足しています. あなたの残高: #{max_thx}thx",
              response_type: "ephemeral",
              replace_original: false
            }
          else
            ApplicationRecord.transaction do
              thx_transaction = ThxTransaction.new(thx_hash: SecureRandom.hex,
                                                   sender: sender,
                                                   receiver: receiver,
                                                   thx: thx.to_i,
                                                   comment: nil)
              sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
              receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
              thx_transaction.save!
            end
            {
              text: "#{receiver.name}さんに#{thx}ポイントを送りました！:tada:",
              response_type: "ephemeral",
              replace_original: false
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
              icon_emoji: ':thx:',
              attachments: [
                {
                  text: "あなたはもうすでにThxに参加しています :ok:\n\"/thx_help\"で使い方を見れます :eyes:",
                  color: 'good'
                },
                {
                  fallback: "",
                  footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                }
              ]
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
              icon_emoji: ':thx:',
              attachments: [
                {
                  text: "#{res_user['name']}, Welcome to thx! :wave: \nThis system is for Peer-To-Peer Bonus.\nhow to use:eyes: ```/thx_help``` ",
                  color: 'good'
                },
                {
                  fallback: "",
                  footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
                }
              ]
            }
          end
        end
      end
    end
  end

  def not_registered
    {
      attachments: [
        {
          text: "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます",
          color: 'danger',
          footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
        }
      ]
    }
  end

  def not_receiver_registered
    {
      attachments: [
        {
          text: "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます",
          color: 'danger',
          footer: "#thx_infoでリリース情報&ランキングが見れます。不具合は#thx_developerまでお知らせください"
        }
      ]
    }
  end
end