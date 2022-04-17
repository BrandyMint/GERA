# frozen_string_literal: true

module Gera
  class RateSourceBitfinex < RateSource

    def tickers_to_load
      currencies_tickers
    end

    def currencies_tickers
      buffer = []
      Currency.alive.find_each do |c1|
        Currency.alive.find_each do |c2|
          ticker = c1.bitfinex_ticker + c2.bitfinex_ticker
          buffer << ticker if supported_tickers.include? ticker
          ticker = c2.bitfinex_ticker + c1.bitfinex_ticker
          buffer << ticker if supported_tickers.include? ticker
        end
      end
      buffer.freeze
    end
  end
end
