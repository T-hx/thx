module Slacks
  class V1 < Grape::API
    # /v1/slack
    resource 'slack' do
      resource 'thxes' do
        # POST /v1/slack/thxes
        desc 'thx残高,獲得数などの確認'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post '/', jbuilder: 'v1/slacks/me' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          @user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
        end

        # POST /v1/slack/thxes/comments
        desc 'show comments'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'comments', jbuilder: 'v1/slacks/comments' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          @user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          @thxes = ThxTransaction.where(receiver: @user).last(10)
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
            max_thx = sender&.thx_balance
            @send_data = {receiver: receiver, sender: sender, max_thx: max_thx, thx: thx.to_i}
            if receiver && sender && max_thx > thx.to_i && sender != receiver
              ApplicationRecord.transaction do
                thx_transaction = ThxTransaction.new(thx_hash: SecureRandom.hex,
                                                     sender: sender,
                                                     receiver: receiver,
                                                     thx: thx.to_i,
                                                     comment: comment)
                sender.update!(thx_balance: (sender.thx_balance - thx.to_i))
                receiver.update!(received_thx: (receiver.received_thx + thx.to_i))
                thx_transaction.save!
                @send_data[:thx_transaction] = thx_transaction
              end
            end
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

        # POST /v1/slack/thxes/register
        desc 'ユーザーの追加'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザID'
        end
        post 'register', jbuilder: 'v1/slacks/register' do
          st_params = strong_params(params).permit(:team_id, :user_id)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          if user.nil?
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

        # POST /v1/slack/thxes/report
        desc 'レポート出力'
        params do
          requires :team_id, type: String, desc: 'チームID'
          requires :user_id, type: String, desc: 'ユーザーID'
          requires :text, type: String, desc: 'レポートの種類'
        end
        post 'report', jbuilder: 'v1/slacks/report' do
          st_params = strong_params(params).permit(:team_id, :user_id, :text)
          user = User.find_by(slack_team_id: st_params[:team_id], slack_user_id: st_params[:user_id])
          if user == ENV[:REPORT_USER]
            begin
              Object.const_get("SlackReporter::#{st_params[:text]}").report
              @message = "#{st_params[:text]}レポート出力に成功しました"
            rescue
              @message = 'レポートの出力に失敗しました'
            end
          else
            @message = 'レポート出力の権限がありません'
          end
        end
      end
    end
  end
end