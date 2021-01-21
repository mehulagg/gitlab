# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Scanner do
  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:params) do
      {
        external_id: 'brakeman',
        name: 'Brakeman',
        vendor: 'GitLab'
      }
    end

    context 'when all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          external_id: 'brakeman',
          name: 'Brakeman',
          vendor: 'GitLab'
        )
      end
    end

    %i[external_id name].each do |attribute|
      context "when attribute #{attribute} is missing" do
        before do
          params.delete(attribute)
        end

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#key' do
    let(:scanner) { create(:ci_reports_security_scanner) }

    subject { scanner.key }

    it 'returns external_id' do
      is_expected.to eq(scanner.external_id)
    end
  end

  describe '#to_hash' do
    let(:scanner) { create(:ci_reports_security_scanner) }

    subject { scanner.to_hash }

    it 'returns expected hash' do
      is_expected.to eq({
        external_id: scanner.external_id,
        name: scanner.name,
        vendor: scanner.vendor
      })
    end

    context 'when vendor is not defined' do
      let(:scanner) { create(:ci_reports_security_scanner, vendor: nil) }

      it 'returns expected hash' do
        is_expected.to eq({
          external_id: scanner.external_id,
          name: scanner.name
        })
      end
    end
  end

  describe '#==' do
    using RSpec::Parameterized::TableSyntax

    where(:id_1, :id_2, :equal, :case_name) do
      'brakeman' | 'brakeman' | true  | 'when external_id is equal'
      'brakeman' | 'bandit'   | false | 'when external_id is different'
    end

    with_them do
      let(:scanner_1) { create(:ci_reports_security_scanner, external_id: id_1) }
      let(:scanner_2) { create(:ci_reports_security_scanner, external_id: id_2) }

      it "returns #{params[:equal]}" do
        expect(scanner_1 == scanner_2).to eq(equal)
      end
    end
  end
end
