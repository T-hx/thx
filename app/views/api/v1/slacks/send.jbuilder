if @send_data.blank?
  json.attachments do
    json.child! do
      json.partial! 'v1/slacks/partial/_invalid_param'
    end
  end
elsif @send_data[:sender].nil?
  json.attachments do
    json.child! do
      json.partial! 'v1/slacks/partial/_not_registered'
    end
  end
elsif @send_data[:receiver].nil?
  json.attachments do
    json.child! do
      json.partial! 'v1/slacks/partial/_not_receiver_registered'
    end
  end
elsif @send_data[:sender] == @send_data[:receiver]
  json.attachments do
    json.child! do
      json.partial! 'v1/slacks/partial/_error_send_myself'
    end
  end
elsif @send_data[:max_thx] < @send_data[:thx]
  json.attachments do
    json.child! do
      json.partial! 'v1/slacks/partial/_not_enough_thx'
    end
  end
elsif @send_data.all? {|k, v| v.present?}
  json.response_type 'in_channel'
  json.attachments do
    json.child! do
      json.text "#{@send_data[:thx_transaction].sender.name}さんが#{@send_data[:thx_transaction].receiver.name}さんに#{@send_data[:thx_transaction].thx}thx送りました！:tada:"
      json.color 'good'
      json.fields do
        json.child! do
          json.title 'comment'
          json.value @send_data[:thx_transaction].comment
          json.short false
        end
      end
    end
  end
end
