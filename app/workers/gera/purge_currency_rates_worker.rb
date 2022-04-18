# frozen_string_literal: true

module Gera
  class PurgeCurrencyRatesWorker
    include Sidekiq::Worker

    sidekiq_options queue: :purgers, retry: false

    KEEP_PERIOD = 1.week

    PURGE_METHOD = :delete_all

    def perform
      if PURGE_METHOD == :delete_all
        currency_rates.delete_all
        currency_rate_snapshots.delete_all
      else
        currency_rate_snapshots.batch_purge batch_size: 100
      end
    end

    private

    def current_snapshot
      @current_snapshot ||= Gera::CurrencyRateSnapshot.order('created_at desc').first
    end

    def currency_rates
      CurrencyRate.where.not(snapshot_id: current_snapshot.id).where('created_at < ?', KEEP_PERIOD.ago)
    end

    def currency_rate_snapshots
      CurrencyRateSnapshot.where.not(id: current_snapshot.id).where('created_at < ?', KEEP_PERIOD.ago)
    end
  end
end
