if @user.nil?
  json.attachments do
    json.child! do
      json.text "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます"
      json.color 'danger'
      json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
    end
  end
else
  json.attachments do
    json.child! do
      json.color 'good'
      json.title 'Thx List'
      json.text 'あなたに送られたthx一覧です。直近の10件を表示しています。'
      json.title_link 'https://api.slack.com/'
      json.fields @thxes do |thx|
        json.title "#{thx.thx}thx from #{thx.sender&.name}"
        json.value thx.comment
        json.short true
      end
      json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
    end
  end
end
