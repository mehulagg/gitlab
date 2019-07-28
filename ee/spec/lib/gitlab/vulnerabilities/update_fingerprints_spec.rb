# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Vulnerabilities::UpdateFingerprints do
  describe '#update_all' do
    it 'updates project_fingerprint on vulnerability feedback and occurrences to use the canonical method' do
      metadata = {
        cve: 'new_fingerprint',
      }.to_json
      old_fingerprint_1 = Digest::SHA1.hexdigest('old_fingerprint_1')
      old_fingerprint_2 = Digest::SHA1.hexdigest('old_fingerprint_2')
      old_fingerprint_3 = Digest::SHA1.hexdigest('old_fingerprint_3')
      new_fingerprint = Digest::SHA1.hexdigest('new_fingerprint')
      occurrence_with_feedback = create(
        :vulnerabilities_occurrence,
        project_fingerprint: old_fingerprint_1,
        raw_metadata: metadata
      )
      occurrence_without_feedback = create(:vulnerabilities_occurrence, project_fingerprint: old_fingerprint_2)
      feedback_with_occurrence = create(:vulnerability_feedback, project_fingerprint: old_fingerprint_1)
      feedback_with_occurrence_2 = create(:vulnerability_feedback, project_fingerprint: old_fingerprint_1)
      feedback_without_occurrence = create(:vulnerability_feedback, project_fingerprint: old_fingerprint_3)

      Gitlab::Vulnerabilities::UpdateFingerprints.new.update_all

      expect(occurrence_without_feedback.reload.project_fingerprint).to eq(old_fingerprint_2)
      expect(feedback_without_occurrence.reload.project_fingerprint).to eq(old_fingerprint_3)
      expect(occurrence_with_feedback.reload.project_fingerprint).to eq(new_fingerprint)
      expect(feedback_with_occurrence.reload.project_fingerprint).to eq(new_fingerprint)
      expect(feedback_with_occurrence_2.reload.project_fingerprint).to eq(new_fingerprint)
    end

    context 'when the occurrence is from a DAST report' do
      it 'generates the fingerprint from the pluginid' do
        metadata = {
          pluginid: 'new_fingerprint',
          riskcode: '1',
          confidence: '1',
          reference: ''
        }.to_json
        old_fingerprint = Digest::SHA1.hexdigest('old_fingerprint')
        new_fingerprint = Digest::SHA1.hexdigest('new_fingerprint')
        dast_occurrence = create(
          :vulnerabilities_occurrence,
          report_type: :dast,
          project_fingerprint: old_fingerprint,
          raw_metadata: metadata
        )
        feedback = create(:vulnerability_feedback, project_fingerprint: old_fingerprint)

        Gitlab::Vulnerabilities::UpdateFingerprints.new.update_all

        expect(dast_occurrence.reload.project_fingerprint).to eq(new_fingerprint)
        expect(feedback.reload.project_fingerprint).to eq(new_fingerprint)
      end
    end

    context 'when the occurrence is from a container scanning report' do
      it 'generates the fingerprint from vulnerability' do
        metadata = {
          vulnerability: 'new_fingerprint',
          severity: 'Low',
        }.to_json
        old_fingerprint = Digest::SHA1.hexdigest('old_fingerprint')
        new_fingerprint = Digest::SHA1.hexdigest('new_fingerprint')
        container_scanning_occurrence = create(
          :vulnerabilities_occurrence,
          report_type: :container_scanning,
          project_fingerprint: old_fingerprint,
          raw_metadata: metadata
        )
        feedback = create(:vulnerability_feedback, project_fingerprint: old_fingerprint)

        Gitlab::Vulnerabilities::UpdateFingerprints.new.update_all

        expect(container_scanning_occurrence.reload.project_fingerprint).to eq(new_fingerprint)
        expect(feedback.reload.project_fingerprint).to eq(new_fingerprint)
      end
    end
  end
end
