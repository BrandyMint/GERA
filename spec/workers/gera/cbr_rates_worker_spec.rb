# frozen_string_literal: true

require 'spec_helper'

module Gera
  RSpec.describe CBRRatesWorker do
    before do
      create :rate_source_exmo
      create :rate_source_cbr_avg
      create :rate_source_cbr
    end
    let(:today) { Date.parse '13/03/2018' }
    it do
      expect(ExternalRate.count).to be_zero
      allow(Date).to receive(:today).and_return today
      Timecop.freeze(today) do
        VCR.use_cassette :cbrf do
          expect(CBRRatesWorker.new.perform).to be_truthy
        end
      end

      expect(ExternalRate.count).to eq 16
    end
  end
end
