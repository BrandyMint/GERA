# frozen_string_literal: true

module Gera
  class ExternalRateSnapshot < ApplicationRecord
    belongs_to :rate_source

    has_many :external_rates, foreign_key: :snapshot_id

    before_save do
      self.actual_for ||= Time.zone.now
    end

    def to_s
      "snapshot[#{id}]:#{rate_source}:#{actual_for}"
    end
  end
end
