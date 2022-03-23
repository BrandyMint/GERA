class AddPhoneAndTelegramToPaymentSystemd < ActiveRecord::Migration[5.2]
  def change
    add_column :gera_payment_systems, :require_phone_on_income, :boolean, default: false, null: false
    add_column :gera_payment_systems, :require_phone_on_outcome, :boolean, default: false, null: false

    add_column :gera_payment_systems, :require_telegram_on_income, :boolean, default: false, null: false
    add_column :gera_payment_systems, :require_telegram_on_outcome, :boolean, default: false, null: false
  end
end
