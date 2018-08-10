json.attachments do
  json.child! do
    json.color 'good'
    json.text "#{@thx_transaction.receiver.name}さんに#{@thx_transaction.thx}ポイントを送りました！:tada:"
    json.response_type 'ephemeral'
    json.replace_original false
  end
end
