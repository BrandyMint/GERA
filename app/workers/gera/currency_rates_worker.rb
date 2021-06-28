# frozen_string_literal: true

module Gera
  #
  # Build currency rates on base of imported rates and calculation modes
  #
  class CurrencyRatesWorker
    include Sidekiq::Worker
    include AutoLogger

    Error = Class.new StandardError

    def perform
      logger.info 'start'

      CurrencyRate.transaction do
        @snapshot = create_snapshot

        Gera::CurrencyPair.all.each do |pair|
          create_rate pair
        end
      end

      logger.info 'finish'

      DirectionsRatesWorker.perform_async

      snapshot
    end

    private

    attr_reader :snapshot

    def create_snapshot
      CurrencyRateSnapshot.create! currency_rate_mode_snapshot: Universe.currency_rate_modes_repository.snapshot
    end

    def create_rate(pair)
      crm = Universe.currency_rate_modes_repository.find_currency_rate_mode_by_pair pair

      logger.debug "build_rate(#{pair}, #{crm || :default})"

      crm ||= CurrencyRateMode.new(currency_pair: pair, mode: :auto).freeze

      cr = crm.build_currency_rate

      raise Error, "Can not calculate rate of #{pair} for mode '#{crm.try :mode}'" unless cr.present?

      cr.snapshot = snapshot
      cr.save!
    rescue StandardError => err
      logger.error err
      raise err if !err.is_a?(Error) && Rails.env.test?

      Rails.logger.error err if Rails.env.development?
      if defined? Bugsnag
        Bugsnag.notify err do |b|
          b.meta_data = { pair: pair }
        end unless err.is_a? Error
      end
    end
  end
end
