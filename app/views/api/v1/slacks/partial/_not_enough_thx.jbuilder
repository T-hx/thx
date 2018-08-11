json.text "thxが不足しています。 あなたの残高: #{@send_data[:max_thx]}thx"
json.color 'danger'
json.partial! 'v1/slacks/partial/_footer'
