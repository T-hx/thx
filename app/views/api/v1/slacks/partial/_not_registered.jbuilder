json.attachments do
  json.child! do
    json.text "あなたはまだThxに登録されていません.:ghost:\n\"/thx_register\"コマンドを実行することで登録できます"
    json.color 'danger'
    json.partial! 'footer'
  end
end

