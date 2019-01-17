module ErrorReporter
  # Bugsnagに通知します。
  #
  def self.notify_error(ex, data={})
    Bugsnag.notify(ex, data)
  end
end