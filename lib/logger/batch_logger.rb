class BatchLogger < Logger
  def format_message(severity, timestamp, progname, data)
    data[:time] ||= Time.now.localtime
    data[:host] ||= Socket.gethostname
    LTSV.dump(data) << "\n"
  end
end

BATCH_LOGGER = BatchLogger.new("#{Rails.root}/log/batch.log", 5, 10.megabytes)
