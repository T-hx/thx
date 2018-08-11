return json.partial! 'partial/not_registered' if @user.nil?
json.attachments do
  json.child! do
    json.color 'good'
    json.title 'Thx List'
    json.text 'あなたに送られたthx一覧です。直近の10件を表示しています。'
    json.title_link 'https://api.slack.com/'
    json.fields @thxes do |thx|
      puts thx.sender.inspect
      json.title "#{thx.thx} from #{thx.sender.name}"
      json.text thx.comment
      json.short true
    end
    json.partial! 'partial/footer'
  end
end
