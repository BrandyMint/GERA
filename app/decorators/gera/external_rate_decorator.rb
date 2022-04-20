# frozen_string_literal: true

module Gera
  class ExternalRateDecorator < ApplicationDecorator
    delegate_all

    def rate_value
      h.rate_humanized_description(object.rate_value, cur_from, cur_to)
    end
  end
end
