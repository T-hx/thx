module SlackReporter
  class Base
    include ::Batch
    class << self
      def run
        puts "[start] #{self.name} report start"
        notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
        notifier.ping(build_message)
        puts "[success] #{self.name} report success"
      rescue => e
        puts "[error] #{e.inspect}\n#{e.backtrace.join("\n")}"
      ensure
        puts "[end] #{self.name} report end"
      end

      def build_message
        'Called abstract method'
      end
    end
  end
end

