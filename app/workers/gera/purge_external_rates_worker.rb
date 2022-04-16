# frozen_string_literal: true

module Gera
  class PurgeExternalRatesWorker
    include Sidekiq::Worker

    sidekiq_options queue: :purgers, retry: false

    KEEP_PERIOD = 1.week

    PURGE_METHOD = :delete_all

    def perform
      if PURGE_METHOD == :delete_all
        external_rate_snapshots.delete_all
      else
        external_rate_snapshots.batch_purge
      end
    end

    private

    def lock_timeout
      7.days * 1000
    end

    def external_rate_snapshots
      ExternalRateSnapshot.where.not(id: ExternalRateSnapshot.last).where('created_at < ?', KEEP_PERIOD.ago)
    end
  end
end
