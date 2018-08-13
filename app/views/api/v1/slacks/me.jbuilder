json.attachments do
  json.child! do
    if @user.nil?
      json.partial! 'v1/slacks/partial/_not_registered'
    else
      json.color 'good'
      json.title "My Thx ( #{@user.name} )"
      json.title_link 'https://api.slack.com/'
      json.fields do
        json.child! do
          json.title '今月のthx残高'
          json.value "#{@user.thx_balance}thx"
          json.short true
        end
        json.child! do
          json.title '総獲得数'
          json.value "#{@user.received_thx}thx"
          json.short true
        end
        json.child! do
          json.title '総送信数'
          json.value 'processing'
          json.short true
        end
        json.child! do
          json.title '総受信数'
          json.value 'processing'
          json.short true
        end
      end
      json.partial! 'v1/slacks/partial/_footer'
    end
  end
end
