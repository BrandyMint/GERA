class AddFetcherKlassToRateSources < ActiveRecord::Migration[5.2]
  def change
    add_column :gera_rate_sources, :fetcher_klass, :string
  end
end
