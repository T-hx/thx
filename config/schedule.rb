# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

rails_env = ENV['RAILS_ENV'] ||= 'production'
ENV.each { |k, v| env(k, v) }
set :output, "log/cron.log"
set :environment, rails_env

every :monday, at: '3am' do
  runner 'Batches::SlackReporter::WeeklyThxRanking.run'
end

every :month, at: '3am' do
  runner 'Batches::SlackReporter::MonthlyThxRanking.run'
end

every :month, at: '3am' do
  runner 'Batches::GiveThx.run'
end
