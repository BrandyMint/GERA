# frozen_string_literal: true

module Gera
  class CBRAvgRatesFetcher
    include AutoLogger

    attr_reader :source

    def perform(source)
      @source = source
      raise 'not working, fix sell_price'
      ActiveRecord::Base.connection.clear_query_cache
      source.with_lock do
        source.available_pairs.each do |pair|
          create_rate pair
        end
        source.update_attribute :actual_snapshot_id, snapshot.id
      end
    end

    private

    def snapshot
      @snapshot ||= source.snapshots.create!
    end

    def create_rate(pair)
      er = RateSourceCBR.enabled.take.find_rate_by_currency_pair pair
      if er.nil?
        logger.error("No cbr sourced currency pair #{pair}")
        return
      end

      price = (er.sell_price + er.buy_price) / 2.0

      # TODO create with create_external_rates
      ExternalRate.create!(
        source: source,
        snapshot: snapshot,
        currency_pair: pair,
        sell_price: price,
        buy_price: price
      )
    end
  end
end
