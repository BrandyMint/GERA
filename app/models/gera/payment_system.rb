# frozen_string_literal: true

module Gera
  class PaymentSystem < ApplicationRecord
    include ::Archivable
    include Gera::Mathematic
    include Authority::Abilities

    scope :ordered, -> { order :priority }
    scope :enabled, -> { where 'income_enabled or outcome_enabled' }
    scope :disabled, -> { where income_enabled: false, outcome_enabled: false }
    scope :available, -> { where is_available: true }

    # TODO: move to kassa-admin
    enum total_computation_method: %i[regular_fee reverse_fee]
    enum transfer_comission_payer: %i[user shop], _prefix: :transfer_comission_payer

    validates :name, presence: true, uniqueness: true
    validates :currency, presence: true

    before_create do
      self.priority = self.class.maximum(:priority).to_i + 1
    end

    after_create :create_exchange_rates

    alias_attribute :deleted_at, :archived_at
    alias_attribute :enable_income, :income_enabled
    alias_attribute :enable_outcome, :outcome_enabled

    delegate :is_crypto?, to: :currency

    monetize :minimal_income_amount_cents, as: :minimal_income_amount, allow_nil: false, with_model_currency: :currency_iso_code
    monetize :maximal_income_amount_cents, as: :maximal_income_amount, allow_nil: true, with_model_currency: :currency_iso_code
    monetize :minimal_outcome_amount_cents, as: :minimal_outcome_amount, allow_nil: true, with_model_currency: :currency_iso_code
    monetize :maximal_outcome_amount_cents, as: :maximal_outcome_amount, allow_nil: true, with_model_currency: :currency_iso_code

    validate :minimals_less_than_maximals

    before_update if: :currency_iso_code_changed? do
      raise "Changing currency is disabled"
    end

    def currency
      return unless currency_iso_code

      Money::Currency.find(currency_iso_code) || raise("No currency found #{currency_iso_code}")
    end

    def currency=(value)
      if value.blank?
        self.currency_iso_code = nil
      elsif value.is_a? Money::Currency
        self.currency_iso_code = value.iso_code
      elsif value.is_a? String
        self.currency_iso_code = (Money::Currency.find(value) || raise("No currency found #{value}")).iso_code
      else
        raise "Unknown currency value type #{value.class}"
      end
      self.currency
    end

    def to_s
      name
    end

    # TODO: move to kassa-admin
    def total_with_fee(money)
      calculate_total(money: money, fee: transfer_fee)
    end

    def unverified_total_with_fee(money)
      calculate_total(money: money, fee: unverified_transfer_fee)
    end

    private

    def minimals_less_than_maximals
      errors.add :minimal_income_amount, 'Минимальная сумма на вход должна быть меньше максимальной' if minimal_income_amount>=maximal_income_amount
      errors.add :minimal_income_amount, 'Минимальная сумма на выход должна быть меньше максимальной' if minimal_outcome_amount>=maximal_outcome_amount
    end

    def calculate_total(money:, fee:)
      if fee.computation_method == 'regular_fee'
        calculate_total_using_regular_comission(money, fee.amount)
      elsif fee.computation_method == 'reverse_fee'
        calculate_total_using_reverse_comission(money, fee.amount)
      else
        raise NotImplementedError, "Нет расчета для #{fee.computation_method}"
      end
    end

    def transfer_fee
      OpenStruct.new(
        amount: income_fee,
        computation_method: total_computation_method
      ).freeze
    end

    def unverified_transfer_fee
      OpenStruct.new(
        amount: unverified_income_fee,
        computation_method: total_computation_method
      ).freeze
    end

    DEFAULT_COMMISSION = 10

    def create_exchange_rates
      PaymentSystem.pluck(:id).each do |foreign_id|
        ExchangeRate
          .create_with(commission: DEFAULT_COMMISSION)
          .find_or_create_by(payment_system_from_id: id, payment_system_to_id: foreign_id)

        ExchangeRate
          .create_with(commission: DEFAULT_COMMISSION)
          .find_or_create_by(payment_system_from_id: foreign_id, payment_system_to_id: id)
      end
    end
  end
end
