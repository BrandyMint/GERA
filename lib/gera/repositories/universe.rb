require 'request_store'

module Gera
  class Universe
    class << self
      delegate :currency_rate_modes_repository, :currency_rates_repository, :direction_rates_repository, :exchange_rates_repository,
        :payment_systems,
        to: :instance

      def instance
        RequestStore[:universe_repository] ||= new
      end
    end

    def payment_systems
      @payment_systems ||= PaymentSystemsRepository.new
    end

    def currency_rate_modes_repository
      @currency_rate_modes_repository ||= CurrencyRateModesRepository.new
    end

    def currency_rates_repository
      @currency_rates_repository ||= CurrencyRatesRepository.new
    end

    def direction_rates_repository
      @direction_rates_repository ||= DirectionRatesRepository.new
    end

    def exchange_rates_repository
      @exchange_rates_repository ||= ExchangeRatesRepository.new
    end
  end
end
