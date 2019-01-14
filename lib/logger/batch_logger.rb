class BatchLogger < Logger

  @instance = BatchLogger.new("#{Rails.root}/log/batch.log",
                              5, 10.megabytes)

  def format_message(severity, timestamp, progname, data)
    data[:time] ||= Time.now.localtime
    data[:host] ||= Socket.gethostname
    LTSV.dump(data) << "\n"
  end

  def self.instance
    @instance
  end

  private_class_method :new
end

BATCH_LOGGER = BatchLogger.instance
