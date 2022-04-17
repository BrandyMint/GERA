# frozen_string_literal: true

module Gera
  # Exchange Direction
  #
  class Direction
    include Virtus.model

    attribute :ps_from # , PaymentSystem
    attribute :ps_to   # , PaymentSystem

    alias_attribute :payment_system_from, :ps_from
    alias_attribute :payment_system_to, :ps_to
    alias_attribute :income_payment_system, :ps_from
    alias_attribute :outcome_payment_system, :ps_to

    delegate :id, to: :ps_to, prefix: true, allow_nil: true
    delegate :id, to: :ps_from, prefix: true, allow_nil: true
    delegate :minimal_income_amount, to: :direction_rate, allow_nil: true

    def disable_reasons
      return @disable_reasons if @disable_reasons.is_a? Set
      @disable_reasons = Set.new
      @disable_reasons << :no_alive_income_wallet if ps_from.wallets.alive.income.empty?
      @disable_reasons << :no_direction_rate if direction_rate.blank? || !direction_rate.persisted?
      @disable_reasons << :no_reserves if ReservesByPaymentSystems.new.final_reserves.fetch(ps_to.id).zero?
      @disable_reasons
    end

    def freeze
      disable_reasons
      super
    end

    def exchange_enabled?
      disable_reasons.empty?
    end

    def valid?
      income_payment_system.present? || outcome_payment_system.present?
    end

    def currency_from
      payment_system_from.currency
    end

    def currency_to
      payment_system_to.currency
    end

    def inspect
      to_s
    end

    def to_s
      "direction:#{payment_system_from.try(:id) || '???'}-#{payment_system_to.try(:id) || '???'}"
    end

    def exchange_rate
      Universe.exchange_rates_repository.find_by_direction self
    end

    def direction_rate
      Universe.direction_rates_repository.find_by_direction self
    end

    def mandatory_direction_rate
      direction_rate ||
        DirectionRate.new(income_payment_system: income_payment_system, outcome_payment_system: outcome_payment_system).freeze
    end
  end
end
