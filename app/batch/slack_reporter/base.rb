module SlackReport
  class Base
    include Batch

    def self.report
      @logger.info '[start] start thx weekly ranking'
      notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
      notifier.ping(build_message)
    rescue => e
      @logger.error "[error] #{e.inspect}\n#{e.backtrace.join("\n")}"
    ensure
      @logger.info "[end] end thx weekly ranking"
    end

    def self.build_message
      'Called abstract method'
    end
  end
end

