json.attachments do
  json.child! do
    json.color 'good'
    json.title "Thx List"
    json.text '受信したthxの直近10件を表示しています'
    json.title_link 'https://api.slack.com/'
    json.fields do
      json.child! do
        json.value @text
        json.short false
      end
    end
    json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
  end
end
