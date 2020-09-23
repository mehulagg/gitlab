# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CompareLicenseScanningReportsService do
  let_it_be(:project) { create(:project, :repository) }
  let(:service) { described_class.new(project, nil) }

  before do
    stub_licensed_features(license_scanning: true)
  end

  describe '#execute' do
    subject { service.execute(base_pipeline, head_pipeline) }

    context 'when head pipeline has license scanning reports' do
      let!(:base_pipeline) { nil }
      let!(:head_pipeline) { create(:ee_ci_pipeline, :with_license_scanning_report, project: project) }

      it 'reports new licenses' do
        expect(subject[:status]).to eq(:parsed)
        expect(subject[:data]['new_licenses'].count).to eq(4)
        expect(subject[:data]['new_licenses']).to include(a_hash_including('name' => 'MIT'))
      end
    end

    context 'when base and head pipelines have test reports' do
      let!(:base_pipeline) { create(:ee_ci_pipeline, :with_license_scanning_report, project: project) }
      let!(:head_pipeline) { create(:ee_ci_pipeline, :with_license_scanning_feature_branch, project: project) }

      it 'reports status as parsed' do
        expect(subject[:status]).to eq(:parsed)
      end

      it 'reports new licenses' do
        expect(subject[:data]['new_licenses'].count).to eq(1)
        expect(subject[:data]['new_licenses']).to include(a_hash_including('name' => 'WTFPL'))
      end

      it 'reports existing licenses' do
        expect(subject[:data]['existing_licenses'].count).to eq(1)
        expect(subject[:data]['existing_licenses']).to include(a_hash_including('name' => 'MIT'))
      end

      it 'reports removed licenses' do
        expect(subject[:data]['removed_licenses'].count).to eq(3)
        expect(subject[:data]['removed_licenses']).to include(a_hash_including('name' => 'New BSD'))
      end
    end

    context 'when head pipeline has corrupted license scanning reports' do
      let!(:base_pipeline) { build(:ee_ci_pipeline, :with_corrupted_license_scanning_report, project: project) }
      let!(:head_pipeline) { build(:ee_ci_pipeline, :with_corrupted_license_scanning_report, project: project) }

      it 'does not expose parser errors' do
        expect(subject[:status]).to eq(:parsed)
      end

      context "when the base pipeline is nil" do
        subject { service.execute(nil, head_pipeline) }

        it 'does not expose parser errors' do
          expect(subject[:status]).to eq(:parsed)
        end
      end
    end
  end
end
