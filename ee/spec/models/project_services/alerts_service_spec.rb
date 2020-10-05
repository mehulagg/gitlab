# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertsService do
  let(:service) { build_stubbed(:alerts_service) }

  describe 'Opsgenie MVC' do
    describe '#opsgenie_mvc_target_url' do
      context 'when enabled' do
        before do
          service.opsgenie_mvc_enabled = true
        end

        it 'validates presence' do
          expect(service).to validate_presence_of(:opsgenie_mvc_target_url)
        end

        describe 'enforces public urls' do
          where(:url, :valid) do
            [
              ['https://appname.app.opsgenie.com/alert/list', true],
              ['https://example.com', true],
              ['http://example.com', true],
              ['http://0.0.0.0', false],
              ['http://127.0.0.1', false],
              ['ftp://example.com', false],
              ['invalid url', false]
            ]
          end

          with_them do
            before do
              service.opsgenie_mvc_target_url = url
            end

            if params[:valid]
              it { expect(service).to be_valid }
            else
              it { expect(service).to be_invalid }
            end
          end
        end
      end

      context 'when disabled' do
        before do
          service.opsgenie_mvc_enabled = false
        end

        it 'does not validate presence' do
          expect(service).not_to validate_presence_of(:opsgenie_mvc_target_url)
        end

        it 'allows any value' do
          service.opsgenie_mvc_target_url = 'any value'
          expect(service).to be_valid
        end
      end
    end

    describe '#opsgenie_mvc_available?' do
      subject { service.opsgenie_mvc_available? }

      before do
        stub_licensed_features(opsgenie_integration: true)
      end

      context 'when license is available' do
        it { is_expected.to eq(true) }
      end

      context 'when license is not available' do
        before do
          stub_licensed_features(opsgenie_integration: false)
        end

        it { is_expected.to eq(false) }
      end

      context 'when template service' do
        let(:service) { build_stubbed(:alerts_service, :template) }

        it { is_expected.to eq(false) }
      end

      context 'when instance service' do
        let(:service) { build_stubbed(:alerts_service, :instance) }

        it { is_expected.to eq(false) }
      end
    end
  end
end
