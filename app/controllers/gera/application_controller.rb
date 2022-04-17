# frozen_string_literal: true

module Gera
  class ApplicationController < ::ApplicationController
    helper Gera::ApplicationHelper
    helper Gera::CurrencyRateModesHelper
    helper Gera::DirectionRateHelper

    protect_from_forgery with: :exception

    ensure_authorization_performed

    helper_method :payment_systems
    helper_method :currencies
    helper_method :query_params

    before_action do
      @container = :fluid
    end

    private

    def query_params
      params.fetch(:q, {}).permit!
    end

    def app_title
      "GERA #{VERSION}"
    end

    def currencies
      if defined? Currency
        Currency.alive.map &:money_currency
      else
        Money::Currency.all
      end
    end

    def payment_systems
      @payment_systems ||= Universe.payment_systems.available.alive.ordered
    end
  end
end
