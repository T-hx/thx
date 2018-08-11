json.attachments do
  json.child! do
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
    json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
  end
end
