if @user.present?
  json.attachments do
    json.child! do
      json.color 'good'
      json.title 'Welcome Thx'
      json.text "#{@user.name} , ようこそ!Thxへ :wave: \nThxはPeer-To-Peerの評価システムです .\n\"/thx_help\"コマンドで使い方を見れます:eyes:\n詳しくはこちら<https://api.slack.com/|ヘルプページ>"
      json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
    end
  end
else
  json.attachments do
    json.child! do
      json.color 'warning'
      json.text 'あなたはもうすでにThxに参加しています :ok:'
      json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
    end
  end
end
