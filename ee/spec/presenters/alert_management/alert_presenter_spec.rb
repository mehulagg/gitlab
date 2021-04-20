# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertPresenter do
  let_it_be(:project) { create(:project) }
  let_it_be(:payload) do
    {
      'title' => 'Alert title',
      'start_time' => '2020-04-27T10:10:22.265949279Z',
      'custom' => {
        'alert' => {
          'fields' => %w[one two]
        }
      },
      'yet' => {
        'another' => 73
      }
    }
  end

  let_it_be(:alert) { create(:alert_management_alert, :threat_monitoring, project: project, payload: payload) }

  subject(:presenter) { described_class.new(alert) }

  describe '#issue_description' do
    let(:markdown_line_break) { '  ' }

    subject { presenter.issue_description }

    context 'with threat monitoring alert' do
      it do
        is_expected.to eq(
          <<~MARKDOWN.chomp
            **Start time:** #{presenter.start_time}#{markdown_line_break}
            **Severity:** #{presenter.severity}#{markdown_line_break}
            **GitLab alert:** http://localhost/#{project.full_path}/-/threat_monitoring/alerts/#{alert.iid}

          MARKDOWN
        )
      end
    end
  end

  describe '#details_url' do
    context 'when alert has threat_monitoring domain' do
      it 'returns the details URL' do
        expect(presenter.details_url).to match(%r{#{project.web_url}/-/threat_monitoring/alerts/#{alert.iid}})
      end
    end
  end
end
