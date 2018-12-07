module Gera
  class RateSourceCBR < RateSource
    def self.supported_currencies
      %i(RUB KZT USD EUR).map { |m| Money::Currency.find! m }
    end

    def self.available_pairs
      [ 'KZT/RUB', 'USD/RUB', 'EUR/RUB' ].map { |cp| Gera::CurrencyPair.new cp }.freeze
    end
  end
end