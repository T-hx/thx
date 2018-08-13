json.attachments do
  json.child! do
    if @user.nil?
      json.partial! 'v1/slacks/partial/_not_registered'
    else
      json.color 'good'
      json.title 'Thx List'
      json.text 'あなたに送られたthx一覧です。直近の受信から最大10件を表示しています。'
      json.title_link 'https://api.slack.com/'
      json.fields @thxes do |thx|
        json.title "#{thx.thx}thx from #{thx.sender&.name}"
        json.value thx.comment
        json.short true
      end
      json.partial! 'v1/slacks/partial/_footer'
    end
  end
end
