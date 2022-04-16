# frozen_string_literal: true

module Gera
  class RateSourceBitfinex < RateSource
    def self.supported_currencies
      # TODO Забирать из Currency
      %i[XMR NEO BTC ETH EUR USD].map { |m| Money::Currency.find! m }
    end
  end
end
