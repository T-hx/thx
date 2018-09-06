json.text "Thxの基本的なコマンドについて説明します"
json.attachments do
  json.child! do
    json.color 'good'
    json.title "Thx help"
    json.fields do
      json.child! do
        json.title 'thxを送信したい'
        json.value "(コマンド)\n/thx @niji-tarou 10 ありがとう\n\n第1引数: 送信先ユーザー選択\n第2引数: 送信したいthx量指定\n第3引数: コメント\n\n注意点:\n1. 各引数の間はスペースを空けてください\n2. 送信先ユーザーの選択はslackのメンション機能をご利用ください\n3. thx残高以下しか送れません\n\nthx送信に失敗した場合エラーメッセージをご確認ください"
        json.short false
      end
      json.child! do
        json.title 'thx残高、獲得thx量などを確認したい'
        json.value "(コマンド)\n/thx-me\n\n引数はいりません"
        json.short false
      end
      json.child! do
        json.title '受信したコメントをみたい'
        json.value "(コマンド)\n/thx-comment\n\n引数はいりません"
        json.short false
      end
      json.child! do
        json.title 'Thxシステムを利用したい'
        json.value "(コマンド)\n/thx-regster\n\n引数はいりません\n\nはじめてthxを利用する場合はこのコマンドが必要になる可能性があります。基本的には新しく入社された方は自動で登録されます。",
                   json.short false
      end
    end
    json.partial! 'v1/slacks/partial/_footer'
  end
end