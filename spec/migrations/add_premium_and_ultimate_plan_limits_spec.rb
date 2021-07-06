# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe AddPremiumAndUltimatePlanLimits, :migration do
  describe '#up' do
    context 'when not .com?' do
      xit 'does nothing'
    end

    context 'when .com?' do
      before do
        allow(Gitlab).to receive(:dev_env_or_com?).and_return true
      end

      context 'when source plan does not exist' do
        xit 'does not create limits'
      end

      context 'when target plan does not exist' do
        xit 'does not create limits'
      end

      context 'when source and target plans exist' do
        context 'when target has plan limits' do
          xit 'does not overwrite the limits'
        end

        context 'when target has no plan limits' do
          xit 'creates plan limits from the source plan'
        end
      end
    end
  end
end
