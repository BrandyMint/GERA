# frozen_string_literal: true

module Gera
  class DirectionRateSnapshot < ApplicationRecord
    has_many :direction_rates, foreign_key: :snapshot_id

    scope :actual, -> {
      where('created_at>=?', Settings.actual_rates.fetch(:direction_rates_seconds).seconds.ago).
      order('created_at desc')
    }
  end
end
