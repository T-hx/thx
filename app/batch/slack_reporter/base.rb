module SlackReporter
  class Base
    include Batch
    class << self
      def run
        @@logger.info "[start] #{self}"
        notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.ping(build_message)
      rescue => e
        @@logger.error "[error] #{e.inspect}\n#{e.backtrace.join("\n")}"
      ensure
        @@logger.info "[end] #{self}"
      end

      def build_message
        'Called abstract method'
      end
    end
  end
end

