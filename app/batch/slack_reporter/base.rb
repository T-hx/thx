module SlackReporter
  class Base
    include ::Batch
    class << self
      def run
        notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.ping(build_message)
      end

      def build_message
        'Called abstract method'
      end
    end
  end
end

