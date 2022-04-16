# frozen_string_literal: true

module Gera
  class PurgeDirectionRatesWorker
    include Sidekiq::Worker

    sidekiq_options queue: :purgers, retry: false

    KEEP_PERIOD = 1.week

    PURGE_METHOD = :delete_all

    def perform
      if PURGE_METHOD == :delete_all
        direction_rates.delete_all
        direction_rate_snapshots.delete_all
      else
        direction_rate_snapshots.batch_purge
        direction_rates.batch_purge
      end
    end

    private

    def lock_timeout
      7.days * 1000
    end

    def direction_rate_snapshots
      DirectionRateSnapshot.where.not(id: DirectionRateSnapshot.last).where('created_at < ?', KEEP_PERIOD.ago)
    end

    def direction_rates
      DirectionRate.where.not(id: DirectionRateSnapshot.last.direction_rates.pluck(:id)).where('created_at < ?', KEEP_PERIOD.ago)
    end
  end
end
