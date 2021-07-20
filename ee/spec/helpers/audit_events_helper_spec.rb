# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEventsHelper do
  describe '#admin_audit_event_tokens' do
    it 'returns the available tokens' do
      available_tokens = [
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:user] },
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:group] },
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:project] }
      ]
      expect(admin_audit_event_tokens).to eq(available_tokens)
    end
  end

  describe '#group_audit_event_tokens' do
    let(:group_id) { 1 }

    it 'returns the available tokens' do
      available_tokens = [{ type: AuditEventsHelper::FILTER_TOKEN_TYPES[:member], group_id: group_id }]
      expect(group_audit_event_tokens(group_id)).to eq(available_tokens)
    end
  end

  describe '#project_audit_event_tokens' do
    let(:project_path) { '/abc' }

    it 'returns the available tokens' do
      available_tokens = [{ type: AuditEventsHelper::FILTER_TOKEN_TYPES[:member], project_path: project_path }]
      expect(project_audit_event_tokens(project_path)).to eq(available_tokens)
    end
  end

  describe '#export_url' do
    subject { export_url }

    it { is_expected.to eq('http://test.host/admin/audit_log_reports.csv') }
  end
end
