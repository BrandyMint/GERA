class Admin::CurrencyRateModesController < Admin::ApplicationController
  authorize_actions_for Gera::CurrencyRateMode

  helper_method :success_url

  def new
    render :edit, locals: {
      currency_rate_mode: snapshot.currency_rate_modes.build(permitted_params)
    }
  end

  def create
    Gera::CurrencyRateMode.create! permitted_params

    flash[:success] = 'Метод создан'
    redirect_to success_url
  rescue ActiveRecord::RecordInvalid => e
    render :edit, locals: { currency_rate_mode: e.record }
  end

  def edit
    render :edit, locals: { currency_rate_mode: currency_rate_mode }
  end

  def update
		currency_rate_mode.update! permitted_params

    flash[:success] = 'Метод изменен'
    redirect_to success_url
  rescue ActiveRecord::RecordInvalid => e
    render :edit, locals: { currency_rate_mode: e.record }
  end

  private

  def snapshot
    @snapshot ||= Gera::Gera::CurrencyRateModeSnapshot.find permitted_params[:currency_rate_mode_snapshot_id]
  end

  def success_url
    params[:back] || edit_admin_currency_rate_mode_snapshot_path(currency_rate_mode.snapshot)
  end

  def currency_rate_mode
    Gera::CurrencyRateMode.find params[:id]
  end

  def current_snapshot
    Gera::Universe.currency_rate_modes_repository.snapshot
  end

  def permitted_params
    params.require(:currency_rate_mode).permit!
  end
end
