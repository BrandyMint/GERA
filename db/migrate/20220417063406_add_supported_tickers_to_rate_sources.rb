class AddSupportedTickersToRateSources < ActiveRecord::Migration[5.2]
  def change
    add_column :gera_rate_sources, :supported_tickers, :jsonb, null: false, default: []
    add_column :gera_rate_sources, :supported_tickers_updated_at, :timestamp
  end
end
