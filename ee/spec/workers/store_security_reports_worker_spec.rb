# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StoreSecurityReportsWorker do
  describe '#perform' do
    let(:group)   { create(:group) }
    let(:project) { create(:project, namespace: group) }
    let(:pipeline) { create(:ci_pipeline, ref: 'master', project: project) }

    before do
      allow(Ci::Pipeline).to receive(:find).with(pipeline.id) { pipeline }
    end

    context 'when at least one security report feature is enabled' do
      where(report_type: [:sast, :dast, :dependency_scanning, :container_scanning])

      with_them do
        before do
          stub_licensed_features(report_type => true)
        end

        it 'executes StoreReportsService for given pipeline' do
          expect(Security::StoreReportsService).to receive(:new)
            .with(pipeline).once.and_call_original

          described_class.new.perform(pipeline.id)
        end
      end
    end

    context "when security reports feature is not available" do
      let(:default_branch) { pipeline.ref }

      it 'does not execute StoreReportsService' do
        expect(Security::StoreReportsService).not_to receive(:new)

        described_class.new.perform(pipeline.id)
      end
    end
  end
end
