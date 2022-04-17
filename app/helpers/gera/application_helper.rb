# frozen_string_literal: true

module Gera
  module ApplicationHelper
    MINIMAL_EPSILON = 0.001

    def humanized_comission(comission)
      buffer = format('%.3f', comission)

      # Убираем нули в конце drop_trailing_zeros
      buffer.gsub(/([.,]\d*)0+$/, '\1')
            .gsub(/[.,]$/, '')
    end

    def humanized_currency_rate(rate_value, pair, currency)
      rate = if rate_value < 1
               format('%.9f', rate_value.to_f)
             else
               format('%.3f', rate_value.to_f)
             end

      if pair.first == currency
        "#{rate} #{currency}" # покупка
      elsif pair.second == currency
        "#{rate} #{currency}" # продажа
      else
        raise
      end
    end

    def rate_source(currency_rate, level = 0)
      if currency_rate.mode_cross?
        buffer = currency_rate_mode_detailed currency_rate, level
        "⟮ <span class='text-muted'>#{buffer}</span> ⟯".html_safe
      else
        buffer = currency_rate.rate_source.presence || currency_rate.mode
        "(#{buffer})".html_safe
      end
    end

    def currency_rate_cell_data_attr(rate)
      {
        toggle: :popover,
        container: :body,
        content: "Calculation method: #{currency_rate_mode_detailed rate}",
        trigger: :hover,
        html: 'true',
        placement: :bottom,
        animation: false,
        delay: 0,
        href: currency_rate_path(rate)
      }
    end

    def rate_diff(rv1, rv2, _reverse = false)
      return rate_diff(1.0 / rv1, 1.0 / rv2, true) if rv1 < 1

      diff = rv2 - rv1
      return 0 if diff.abs.round(3) == 0

      p = 100 * diff / rv2

      buffer = "#{format('%.2f', p.round(3))}%"
      content_tag :span, buffer, data: { toggle: :tooltip, title: "#{rv2} - #{rv1}" }
    end

    def present_direction(ps_from, ps_to)
      "#{ps_icon ps_from}(#{ps_from.currency}) &rarr; #{ps_icon ps_to}(#{ps_to.currency})".html_safe
    end

    def rate_with_currency(rate, currency)
      rate = format('%.12f', rate) if rate.is_a?(Float) && rate < MINIMAL_EPSILON
      "#{rate} <span class=text-muted>#{currency}</span>".html_safe
    end

    def rate_cell_with_currency(rate, currency)
      buffer = [rate_with_currency(rate, currency)]
      buffer << rate_with_currency(rate_inversed(rate), currency) if rate < 1
      [buffer].join('<br/>').html_safe
    end

    # = '%.12f' % humanized_money rate.buy_money
    def humanized_rate(rate, _currency = nil)
      rate = rate.to_f if rate.is_a? Gera::Rate
      if rate.is_a? Money
        raise 'Dont use Money, it has bad round'
        currency = rate.currency
        rate = rate.to_f
      end
      if rate < 1
        rate1 = format('%.3f', (1.0 / rate))
        "<span class=text-muted>1/</span>#{rate1}".html_safe
      else
        format('%.3f', rate)
        # = '%.12f' % humanized_money rate.buy_money
        # humanized_money Money.from_amount(rate, currency)
      end
    end

    def humanized_rate_text(rate, _currency = nil)
      if rate < 1
        rate1 = format('%.3f', (1.0 / rate))
        "1/#{rate1}".html_safe
      else
        format('%.3f', rate)
      end
    end

    def rate_inversed(rate)
      "<span class='text-muted'>(1/#{1.0 / rate.to_f})</span>".html_safe
    end

    def humanized_rate_detailed(rate, separator = ' ')
      buffer = if rate < 1
                 "#{rate}#{separator}#{rate_inversed(rate)}".html_safe
               else
                 rate
               end
      content_tag :span, buffer.to_s, class: 'text-nowrap'
    end

    def smart_currency_rate(cur_from, cur_to, reverse: false)
      method = reverse ? :rate_money : :reverse_rate_money
      pair = Gera::CurrencyPair.new cur_from, cur_to
      rate = Gera::Universe.currency_rates_repository.find_currency_rate_by_pair pair
      link_to gera.currency_rate_path(rate), target: '_blank' do
        humanized_money_with_currency rate.send(method)
      end
    rescue CurrencyRatesRepository::UnknownPair => err
      Rails.logger.error err
      t('.no_currency_rate')
    end
  end
end
