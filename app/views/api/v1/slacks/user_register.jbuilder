json.attachments do
  json.child! do
    json.color 'good',
    json.text "#{@user.name} , Welcome to thx! :wave: \nThis system is for Peer-To-Peer Bonus.\nhow to use:eyes: ```/thx_help``` ",
    json.footer '<#CC5LB48KV|thx-info>でランキングやリリース情報が見れます。不具合や要望、お問い合わせは<#CC57Y681X|thx-developer>でお願いします。'
  end
end
