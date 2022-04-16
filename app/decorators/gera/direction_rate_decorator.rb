# frozen_string_literal: true

module Gera
  class DirectionRateDecorator < ApplicationDecorator
    include Mathematic
    delegate :id

    def inverse_direction
      return t('.no_inverse_direction') unless object.inverse_direction_rate.present?
      h.link_to h.direction_rate_path(object.inverse_direction_rate), class: 'text-muted' do
        dd = DirectionRateDecorator.new(object.inverse_direction_rate)
        buffer = dd.direction
        buffer << ' '
        buffer << dd.rate_value
      end
    end

    def direction
      h.present_direction object.ps_from, object.ps_to
    end

    def title
      [object.ps_from, object.ps_to].join('->')
    end

    def ps_comission
      h.link_to object.ps_comission.to_percent, h.payment_system_path(object.outcome_payment_system)
    end

    def created_at
      h.link_to h.direction_rate_path(object) do
        I18n.l object.created_at, format: :long
      end
    end

    def base_rate_value
      h.link_to h.currency_rate_mode_detailed(object.currency_rate), h.currency_rate_path(object.currency_rate)
    end

    def rate_percent
      h.link_to object.rate_percent.to_percent, h.exchange_rate_path(object.exchange_rate_id)
    end

    def rate_value
      h.rate_humanized_description(object.rate_value, object.ps_from.currency, object.ps_to.currency)
    end
  end
end
