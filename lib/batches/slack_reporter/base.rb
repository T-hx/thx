module Batches
  module SlackReporter
    class Base
      class << self
        def run
          BATCH_LOGGER.info ({
            action: "#{self}#run",
            time: Time.zone.now
          })
          notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
          notifier.ping(build_message)
          BATCH_LOGGER.info({
            action: "#{self}#run",
            result: 'success',
            time: Time.zone.now
          })
        rescue => ex
          BATCH_LOGGER.error ({
            action: "#{self}#run",
            status: 'error',
            message: ex.message,
            backtrace: ex.backtrace
          })
        end

        def build_message
          'Called abstract method'
        end
      end
    end
  end
end
