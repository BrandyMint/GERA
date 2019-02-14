require 'csv'
class Admin::CurrencyRatesController < Admin::ApplicationController
  authority_actions modes: :read, brief: :read
  skip_before_action :verify_authenticity_token, only: [:brief]

  after_action :allow_iframe, only: :brief

  helper_method :source

  def index
    if snapshot.present?
      render locals: {
        rates: snapshot.rates,
        created_at: snapshot.created_at
      }
    else
      render :page, locals: { message: 'Отсутствует текущий снимок курсов' }
    end
  end

  def show
    # TODO удалить
    # ActiveRecord::Base.default_timezone = :utc
    render locals: {
      currency_rate: currency_rate,
      currency_pair: currency_rate.currency_pair
    }
  end

  def modes
    body = CSV.generate do |csv|
      line = ['принимаем\отдаем']
      line += Money::Currency.all.map(&:to_s)
      csv << line
      Money::Currency.all.each do |cur_from|
        line = [cur_from]
        Money::Currency.all.each do |cur_to|
          rate = snapshot.rates.find_by(cur_from: cur_from.iso_code, cur_to: cur_to.iso_code)
          d = CurrencyRateDecorator.decorate rate
          line << d.mode
        end
        csv << line
      end
    end

    respond_to do |format|
      format.html { raise 'Поддерживается только CSV' }
      format.csv { send_data body, filename: "exchange_rates-modes-#{Date.today}.csv"}
    end
  end

  private

  def source
    params[:source]
  end

  def currency_rate
    @currency_rate ||= Gera::CurrencyRate.find params[:id]
  end

  def currency_pair
    @currency_pair ||= Gera::CurrencyPair.new cur_from: params[:cur_from], cur_to: params[:cur_to]
  end

  def snapshot
    Gera::Universe.currency_rates_repository.snapshot
  end
end
