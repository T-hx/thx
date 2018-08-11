module Slacks
  class V1 < Grape::API
    # /v1/slack
    resource 'slack' do
      resource 'thxes' do
        # POST /v1/slack/thxes
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

        # POST /v1/slack/thxes/comments
        desc 'show comments'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'comments', jbuilder: 'v1/slacks/comments' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          thxes = ThxTransaction.where(receiver: user).last(10)
          @text = thxes.map {|thx| "#{thx.thx} thx from #{thx.sender&.name}\n#{thx.comment}"}.join("\n\n")
          not_registered unless user
        end

        # POST /v1/slack/thxes/send
        desc 'thxの送信'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
          requires :text, type: String, desc: 'コマンド引数'
        end
        post 'send', jbuilder: 'v1/slacks/send' do
          st_params = strong_params(params).permit(:team_id, :user_id, :text)
          if /@(?<receiver_id>.+)\|.+[\s　](?<thx>\d+)[\s　](?<comment>.+)/ =~ st_params[:text]
            receiver = User.find_by(slack_user_id: receiver_id, slack_team_id: st_params[:team_id])
            sender = User.find_by(slack_user_id: st_params[:user_id], slack_team_id: st_params[:team_id])
            max_thx = sender.thx_balance
            if sender.nil?
              not_registered
            elsif receiver.nil?
              not_receiver_registered
            elsif sender == receiver
              invalid_send_myself
            elsif thx.to_i > max_thx
              not_enough_thx
            else
              ApplicationRecord.transaction do
                @thx_transaction = ThxTransaction.new(thx_hash: SecureRandom.hex,
                                                     sender: sender,
                                                     receiver: receiver,
                                                     thx: thx.to_i,
                                                     comment: comment)
                sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
                receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
                @thx_transaction.save!
              end
            end
          else
            invalid_command
          end
        end

        # POST /v1/slack/thxes/help
        desc 'thxのhelp'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'help', jbuilder: 'v1/slacks/help' do
        end

        # POST /v1/slacks/thxes/stamp
        # TODO: 自分で送れないようにする
        # TODO: アクティブユーザーが増えたら実装する
        # TODO: リファクタ
        desc '追thx送信'
        post 'stamp', jbuilder: 'v1/slacks/stamp_thx' do
          st_params = strong_params(params)
          payload = JSON.parse(st_params[:payload])
          s_id = payload['actions'][0]['value'].split(' ')[1]
          thx = payload['actions'][0]['value'].split(' ')[0]
          receiver = User.find_by(slack_user_id: s_id, slack_team_id: payload['team']['id'])
          sender = User.find_by(slack_user_id: payload['user']['id'], slack_team_id: payload['team']['id'])
          max_thx = sender.thx_balance
          if sender.nil?
            not_registered
          elsif receiver.nil?
            not_receiver_registered
          elsif sender == receiver
            invalid_send_myself
          elsif thx.to_i > max_thx
            not_enough_thx
          else
            ApplicationRecord.transaction do
              @thx_transaction = ThxTransaction.new(thx_hash: SecureRandom.hex,
                                                   sender: sender,
                                                   receiver: receiver,
                                                   thx: thx.to_i,
                                                   comment: nil)
              sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
              receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
              @thx_transaction.save!
            end
          end
        end

        # POST /v1/slack/thxes/register
        desc 'ユーザーの追加'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'register', jbuilder: 'v1/slacks/register' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          @user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          if @user.nil?
            res = Net::HTTP.get(URI.parse("https://slack.com/api/users.info?token=#{ENV['SLACK_TOKEN']}&user=#{st_params[:user_id]}&pretty=1"))
            pretty_res = JSON.parse(res)
            res_user = pretty_res['user']
            ApplicationRecord::transaction do
              @user = User.new(name: res_user['name'],
                               email: res_user['profile']['email'],
                               slack_user_id: res_user['id'],
                               slack_team_id: res_user['team_id'],
                               address: SecureRandom.hex,
                               thx_balance: User::INIT_THX,
                               password: User::SLACK_USER_DUMMY_PASSWORD,
                               password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                               verified: true)
              @user.save!
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
            footer: footer
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
            footer: footer
          }
        ]
      }
    end

    def already_registered
      {
        attachments: [
          {
            text: 'あなたはもうすでにThxに参加しています :ok:',
            color: 'good',
            footer: footer
          }
        ]
      }
    end

    def invalid_send_myself
      {
        attachments: [
          {
            text: '自分自身にthxを送ることは出来ません><',
            color: 'danger'
          }
        ]
      }
    end

    def not_enough_thx
      {
        attachments: [
          {
            text: "thxが不足しています。 あなたの残高: #{max_thx}thx",
            color: 'danger'
          }
        ]
      }
    end

    def invalid_command
      {
        attachments: [
          {
            text: "ポイントを送るには以下のようにコマンドを入力してください。\n\"/thx @送る相手 ポイント メッセージ\"",
            color: 'danger',
            footer: footer
          }
        ]
      }
    end

    def footer
      '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
    end
  end
end