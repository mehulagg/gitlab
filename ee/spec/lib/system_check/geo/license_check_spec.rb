# frozen_string_literal: true

require 'spec_helper'
require 'rake_helper'

RSpec.describe SystemCheck::Geo::LicenseCheck do
  describe '#check?' do
    subject { described_class.new }

    context 'when in the primary Geo site' do
      before do
        allow(Gitlab::Geo).to receive(:primary?).and_return(true)
      end

      context 'and Geo is enabled' do
        before do
          allow(Gitlab::Geo).to receive(:enabled?).and_return(true)
        end

        context 'and a supporting License exists' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(true)
          end

          it 'passes the check' do
            expect(subject.check?).to be_truthy
          end

          it 'returns an empty string via check_pass' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('')
          end
        end

        context 'and no License supporting Geo is found' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(false)
          end

          it 'fails the check' do
            expect(subject.check?).to be_falsey
          end

          it 'returns an empty string via check_pass' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('')
          end
        end
      end

      context 'and Geo is not enabled' do
        before do
          allow(Gitlab::Geo).to receive(:enabled?).and_return(false)
        end

        context 'but a supporting License exists' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(true)
          end

          it 'passes the check' do
            expect(subject.check?).to be_truthy
          end

          it 'informs the user via check_pass that Geo can be enabled' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('License supports Geo, but Geo is not enabled')
          end
        end

        context 'and no License supporting Geo is found' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(false)
          end

          it 'fails the check' do
            expect(subject.check?).to be_truthy
          end

          it 'informs the user via check_pass that Geo is not supported' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('License does not support Geo, and Geo is not enabled')
          end
        end
      end
    end

    context 'when in a secondary Geo site' do
      before do
        allow(Gitlab::Geo).to receive(:primary?).and_return(false)
      end

      it 'passes the check' do
        allow(Gitlab::Geo).to receive(:license_allows?).and_return(true)
      end

      context 'and Geo is enabled' do
        before do
          allow(Gitlab::Geo).to receive(:enabled?).and_return(true)
        end

        context 'and a supporting License exists' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(true)
          end

          it 'returns an empty string via check_pass' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('')
          end
        end

        context 'and no License supporting Geo is found' do
          before do
            allow(Gitlab::Geo).to receive(:license_allows?).and_return(false)
          end

          it 'informs user that License is only required on a primary site' do
            expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('License only required on a primary site')
          end
        end
      end

      context 'and Geo is not enabled' do
        before do
          allow(Gitlab::Geo).to receive(:enabled?).and_return(false)
        end

        it 'returns an empty string via check_pass' do
          expect(SystemCheck::Geo::LicenseCheck.check_pass).to eq('')
        end
      end
    end
  end
end
