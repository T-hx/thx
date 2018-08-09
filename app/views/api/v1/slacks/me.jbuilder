json.attachments do
  json.color '#36a64f'
  json.title "My Thx ( #{@user.name} )"
  json.title_link 'https://api.slack.com/'
  json.fields do
    json.title '今月のthx残高'
    json.value "#{@user.thx_balance}thx"
    json.short true
  end
  json.fields do
    json.title '総獲得数'
    json.value "#{@user.received_thx}"
    json.short true
  end
  json.fields do
    json.title '総送信数'
    json.value 'processing'
    json.short true
  end
  json.fields do
    json.title '総受信ランキング'
    json.value 'processing'
    json.short true
  end
  json.fields do
    json.title '総送信ランキング'
    json.value 'processing'
    json.short true
  end
  json.fields do
    json.title '総獲得数ランキング'
    json.value 'processing'
    json.short true
  end
  json.footer '<#thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#thx-deloper>でお願いします。'
end
