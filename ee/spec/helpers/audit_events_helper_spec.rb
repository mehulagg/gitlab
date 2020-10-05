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

  describe '#human_text' do
    let(:target_type) { 'User' }
    let(:details) do
      {
        author_name: 'John Doe',
        target_id: 1,
        target_type: target_type,
        target_details: 'Michael'
      }
    end

    subject { human_text(details) }

    context 'when message consist of hash keys' do
      subject { human_text({ remove: 'user_access' }.merge(details))}

      it 'ignores keys that start with start with author_, or target_' do
        expect(subject).to eq 'Remove <strong>user access</strong>    '
      end
    end

    context 'when details contain custom message' do
      let(:custom_message) { 'Custom message <strong>with tags</strong>' }

      subject { human_text( { custom_message: custom_message }.merge(details)) }

      it 'returns custom message' do
        expect(subject).to eq(custom_message)
      end
    end
  end

  describe '#select_keys' do
    it 'returns empty string if key starts with author_' do
      expect(select_keys('author_name', 'John Doe')).to eq ''
    end

    it 'returns empty string if key starts with target_' do
      expect(select_keys('target_name', 'John Doe')).to eq ''
    end

    it 'returns empty string if key is ip_address and the value is blank' do
      expect(select_keys('ip_address', nil)).to eq ''
    end

    it 'returns formatted text if key is ip_address and the value is not blank' do
      expect(select_keys('ip_address', '127.0.0.1')).to eq 'ip_address <strong>127.0.0.1</strong>'
    end

    it 'returns formatted text if key does not start with author_, or target_' do
      expect(select_keys('remove', 'user_access')).to eq 'remove <strong>user_access</strong>'
    end

    it 'returns formatted text with `never expires` if key is expiry_from and the value is blank' do
      expect(select_keys('expiry_from', nil)).to eq 'expiry_from <strong>never expires</strong>'
    end

    it 'returns formatted text with `never expires` if key is expiry_to and the value is blank' do
      expect(select_keys('expiry_to', nil)).to eq 'expiry_to <strong>never expires</strong>'
    end
  end

  describe '#export_url' do
    subject { export_url }

    context 'feature is enabled' do
      before do
        stub_feature_flags(audit_log_export_csv: true)
      end

      it { is_expected.to eq('http://test.host/admin/audit_log_reports.csv') }
    end

    context 'feature is disabled' do
      before do
        stub_feature_flags(audit_log_export_csv: false)
      end

      it { is_expected.to be_empty }
    end
  end
end
