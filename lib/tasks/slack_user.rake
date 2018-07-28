# encoding: utf-8
namespace :slack_user do
  desc 'import slack user'
  task :import => :environment do
    res = Net::HTTP.get(URI.parse("https://slack.com/api/users.list?token=#{ENV['SLACK_TOKEN']}&pretty=1"))
    return if res.blank?
    pretty_res = JSON.parse(res)
    User.where(slack_team_id: pretty_res['members'][0]['team_id']).destroy_all
    slack_users = []
    pretty_res['members'].each do |user|
      next if user['deleted']
      slack_users << User.new(name: user['name'],
                              email: user['profile']['email'],
                              slack_user_id: user['id'],
                              slack_team_id: user['team_id'],
                              address: SecureRandom.hex,
                              thx_balance: User::INIT_THX,
                              password: User::SLACK_USER_DUMMY_PASSWORD,
                              password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                              verified: true)
    end
    User.import slack_users
  end

  desc 'add slack user'
  task :add => :environment do
    res = Net::HTTP.get(URI.parse("https://slack.com/api/users.list?token=#{ENV['SLACK_TOKEN']}&pretty=1"))
    return if res.blank?
    pretty_res = JSON.parse(res)
    slack_users = []
    pretty_res['members'].each do |user|
      next if user['deleted']
      next if User.where(slack_user_id: user['id'], slack_team_id: user['team_id']).present?
      slack_users << User.new(name: user['name'],
                              email: user['profile']['email'],
                              slack_user_id: user['id'],
                              slack_team_id: user['team_id'],
                              address: SecureRandom.hex,
                              thx_balance: User::INIT_THX,
                              password: User::SLACK_USER_DUMMY_PASSWORD,
                              password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                              verified: true)
    end
    User.import slack_users
  end

  desc 'refresh slack user'
  task :refresh => :environment do
    res = Net::HTTP.get(URI.parse("https://slack.com/api/users.list?token=#{ENV['SLACK_TOKEN']}&pretty=1"))
    return if res.blank?
    pretty_res = JSON.parse(res)
    slack_users = []
    pretty_res['members'].each do |user|
      if user['deleted']
        slack_user = User.find_by(slack_user_id: user['id'])
        slack_user.destroy! if slack_user
      elsif User.where(slack_user_id: user['id'], slack_team_id: user['team_id']).blank?
        slack_users << User.new(name: user['name'],
                                email: user['profile']['email'],
                                slack_user_id: user['id'],
                                slack_team_id: user['team_id'],
                                address: SecureRandom.hex,
                                thx_balance: User::INIT_THX,
                                password: User::SLACK_USER_DUMMY_PASSWORD,
                                password_confirmation: User::SLACK_USER_DUMMY_PASSWORD,
                                verified: true)
      end
    end
    User.import slack_users
  end
end
