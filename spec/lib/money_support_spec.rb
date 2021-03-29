# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Gera define money' do
  it { expect(Money::Currency.all.count).to eq 22 }
  it { expect(USD).to be_a Money::Currency }
end
