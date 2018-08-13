module SlackReporter
  class Base
    include ::Batch
    class << self
      def report
        puts '[start] start report'
        notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.ping(build_message)
        puts '[success] success report'
      rescue => e
        puts "[error] #{e.inspect}\n#{e.backtrace.join("\n")}"
      ensure
        puts '[end] end report'
      end

      def build_message
        'Called abstract method'
      end
    end
  end
end

