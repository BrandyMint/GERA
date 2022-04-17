# frozen_string_literal: true

require_relative 'application_controller'
module Gera
  class CurrencyRateSnapshotsController < ApplicationController
    authorize_actions_for CurrencyRate

    PER_PAGE = 50

    def index
      render locals: {
        snapshots: snapshots
      }
    end

    def show
      snapshot = CurrencyRateSnapshot.find params[:id]

      render locals: {
        snapshot: snapshot
      }
    end

    private

    def snapshots
      CurrencyRateSnapshot.order('created_at desc').page(params[:page]).per(params[:per] || PER_PAGE)
    end
  end
end
