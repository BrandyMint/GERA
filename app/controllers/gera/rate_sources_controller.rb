# frozen_string_literal: true

require_relative 'application_controller'
module Gera
  class RateSourcesController < ApplicationController
    authorize_actions_for RateSource

    def show
      render locals: { rate_source: rate_source }
    end

    private

    def rate_source
      @rate_source ||= Gera::RateSource.find params[:id]
    end
  end
end
