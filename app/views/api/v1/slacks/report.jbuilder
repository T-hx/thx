json.attachments do
  json.child! do
    json.color 'danger'
    json.text @message
  end
end
