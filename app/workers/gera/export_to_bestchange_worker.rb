# frozen_string_literal: true

# ../kassa-legacy/app/components/ticketsproc/model.php
#
# Скидывает текущий курс в valuta.xml для bestchange
#
# https://www.bestchange.ru/wiki/rates.html
#
require 'benchmark'

module Gera
  class ExportToBestchangeWorker
    include Sidekiq::Worker
    include AutoLogger

    sidekiq_options queue: :critical

    OPTIONS = Rails.env.production? ? { save_with: Nokogiri::XML::Node::SaveOptions::AS_XML } : {}
    MONEY_FORMAT = { with_currency: true, symbol: false, delimiter: nil, separator: '.' }.freeze

    # update_valuta_file
    def perform
      logger.info 'Start'

      size = nil

      bm = Benchmark.measure do
        dom = builder
        logger.info "\tStart dumping XML"
        data = dom.to_xml OPTIONS
        logger.info "\tFinish dumping XML"

        logger.info "\tStart write to file #{valuta_file_path}"
        size = File.atomic_write(valuta_file_path) do |file|
          file.write(data)
        end
        logger.info "\tFinish writing to file. Size is #{size}"
      end
      logger.info "Successful finish (total benchmark: #{bm.real})"
      size
    end

    private

    def lock_timeout
      5
    end

    def builder
      logger.info "\tStart building XML"
      exchange_rates = Gera::ExchangeRate.available.order(:id)

      logger.info "\t\tRates total: #{exchange_rates.count}"
      dumped_count = 0

      dom = Nokogiri::XML::Builder.new do |xml|
        xml.rates do
          exchange_rates.each do |exchange_rate|
            dumped_count += 1 if build_item(xml, exchange_rate)
          end
        end
      end

      logger.info "\t\tRates dumped total: #{dumped_count}"
      logger.info "\tFinish building XML"
      dom
    end

    def snapshot
      @snapshot ||= Gera::DirectionRateSnapshot.actual
    end

    def build_item(xml, exchange_rate)
      direction_rate = Gera::Universe.direction_rates_repository.find_direction_rate_by_exchange_rate_id(exchange_rate.id)
      xml.item do
        # код валюты, которую обменный пункт принимает от клиента. Коды электронных валют приведены в списке ниже;
        xml.from exchange_rate.payment_system_from.bestchange_key

        #  код валюты, которую обменный пункт отправляет клиенту. Коды электронных валют приведены в списке ниже;
        xml.to exchange_rate.payment_system_to.bestchange_key

        # сколько валюты from должен отдать клиент;
        xml.in  direction_rate.out_money

        # сколько валюты to получит клиент;
        xml.out direction_rate.in_money

        # минимальная возможная к обмену сумма валюты, которую обменный пункт принимает от клиента.
        #
        # Если у вас несколько ограничений по минимальной сумме, например, отдельно на прием и на выплату,
        # необходимо указывать в поле minamount максимальное значение такого ограничения,
        # сконвертированное в валюту from. Указывается с кодом национальной валюты.
        #
        # Пример: <minamount>4.1 USD</minamount>;
        xml.minamount direction_rate.minimal_income_amount.format MONEY_FORMAT.dup

        # максимальная возможная к разовому обмену сумма валюты, которую обменный пункт принимает от клиента.
        #
        # Указывается с кодом национальной валюты.
        # Пример: <maxamount>5000 USD</maxamount>
        # Если ограничений по максимальной сумме несколько, например, отдельно на прием и на выплату, необходимо указывать в
        # поле maxamount минимальное значение такого ограничения, сконвертированное в валюту from. Если нет возможности выбрать
        # минимальное значение из нескольких значений максимальных сумм, необходимо указать дополнительные
        # поля maxamount с отдельной максимальной суммой в каждом;
        xml.maxamount get_maxamount(exchange_rate, direction_rate).format MONEY_FORMAT.dup

        xml.amount reserves_service.get_reserve_by_payment_system_id(exchange_rate.payment_system_to_id)

        params = [:manual]
        params << :verifying if exchange_rate.payment_system_to.require_verify? || exchange_rate.payment_system_from.require_verify?

        xml.param params.join(', ')
      end

      true
    rescue Gera::DirectionRatesRepository::FinitRateNotFound => err
      logger.warn err
      Bugsnag.notify err do |b|
        b.meta_data = { exchange_rate_id: exchange_rate.id, exchange_rate_title: exchange_rate.to_s }
      end

      false
    end

    def get_maxamount(exchange_rate, direction_rate)
      reserves =
        reserves_service
        .get_reserve_by_payment_system_id(exchange_rate.payment_system_to_id)
        .to_money(direction_rate.payment_system_to.currency)

      [
        direction_rate.maximal_income_amount,
        direction_rate.reverse_exchange(reserves)
      ].compact.min
    end

    def reservers
      @reservers ||= ReservesByPaymentSystems.final_reserves
    end

    def valuta_file_path
      # TODO: config
      Rails.root.join('./public/uploads/valuta.xml')
    end

    def reserves_service
      @reserves_service ||= ReservesByPaymentSystems.new
    end
  end
end
