json.text "#{@thx_transaction.sender.name}さんが#{@thx_transaction.receiver.name}さんに#{@thx_transaction.thx}thx送りました！:tada:"
json.attachments do
  json.child! do
    json.color 'good'
    json.title 'comment'
    json.text @thx_transaction.comment
  end
end
