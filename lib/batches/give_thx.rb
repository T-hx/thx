module Batches
  class GiveThx
    def self.run
      BATCH_LOGGER.info ({
        action: "Batches::#{self}#run",
        time: Time.zone.now
      })
      giving_history = GivingHistory.order("id desc").limit(1)
      if giving_history.blank? || (giving_history.first.giving_date + GivingHistory::GIVING_PERIOD) <= Time.zone.today
        ApplicationRecord.transaction do
          User.enable.update_all(thx_balance: 0)
          User.enable.update_all(thx_balance: User::INIT_THX)
          GivingHistory.create!(giving_date: Time.zone.today)
        end
      end
      BATCH_LOGGER.info ({
        action: "Batches::#{self}#run",
        result: 'success',
      })
    rescue => ex
      BATCH_LOGGER.error ({
        action: "Batches::#{self}#run",
        result: 'error',
        message: ex.message,
        backtrace: ex.backtrace
      })
    end
  end
end
