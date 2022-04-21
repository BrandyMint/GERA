# frozen_string_literal: true

module Gera
  class RateSourceBitfinex < RateSource
    GERA_TO_SOURCE_MAP = { 'USDT' => 'ust' }
    SOURCE_TO_GERA_MAP = GERA_TO_SOURCE_MAP.invert

    def tickers_to_load
      @tickers_to_load ||= currencies_tickers
    end

    def to_ticker(currency)
      GERA_TO_SOURCE_MAP[currency.iso_code] || currency.iso_code.downcase
    end

    def from_ticker(ticker)
      SOURCE_TO_GERA_MAP[ticker] || ticker.upcase
    end

    def currencies_tickers
      buffer = []
      Currency.alive.find_each do |c1|
        Currency.alive.find_each do |c2|
          ticker = bitfinex_ticker(c1) + bitfinex_ticker(c2)
          buffer << ticker if supported_tickers.include? ticker
          ticker = bitfinex_ticker(c2) + bitfinex_ticker(c1)
          buffer << ticker if supported_tickers.include? ticker
        end
      end
      buffer.freeze
    end
  end
end
