module Gera
  class CurrencyRatesRepository
    UnknownPair = Class.new StandardError

    def snapshot
      @snapshot ||= CurrencyRateSnapshot.
        where('created_at>=?', Settings.actual_rates.fetch(:currency_rates_seconds).seconds.ago).
        order('created_at desc').first ||
        raise("No actual snapshot")
    end

    def find_currency_rate_by_pair pair
      rates_by_pair[pair] || raise(UnknownPair, "Currency pair (#{pair}) is not found in currency rates")
    end

    def get_currency_rate_by_pair pair
      find_currency_rate_by_pair(pair)
    rescue UnknownPair
      CurrencyRate.new(currency_pair: pair).freeze
    end

    private

    def rates_by_pair
      @rates_by_pair ||= snapshot.rates.each_with_object({}) { |r,h| h[r.currency_pair] = r }
    end
  end
end
