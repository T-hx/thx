if @user.present?
  json.attachments do
    json.child! do
      json.color 'good'
      json.title 'Welcome Thx'
      json.text "#{@user.name}さん, ようこそ!Thxへ :wave: \nThxはPeer-To-Peerの評価システムです .\n\"/thx_help\"コマンドで使い方について知ることができます:eyes:\n詳しくは<https://api.slack.com/|ヘルプページ>をご覧ください。"
      json.partial! 'v1/slacks/partial/_footer'
    end
  end
else
  json.attachments do
    json.child! do
      json.color 'warning'
      json.text 'あなたはもうすでにThxに参加しています :ok:'
      json.partial! 'v1/slacks/partial/_footer'
    end
  end
end
