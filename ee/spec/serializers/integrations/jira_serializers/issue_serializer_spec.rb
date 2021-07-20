# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::JiraSerializers::IssueSerializer do
  let_it_be(:project) { create(:project) }
  let_it_be(:jira_integration) { create(:jira_integration, project: project) }

  subject { described_class.new.represent(jira_issues, project: project) }

  describe '#represent' do
    context 'when an empty array is being serialized' do
      let(:jira_issues) { [] }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when multiple objects are being serialized' do
      let(:jira_issues) do
        [double.as_null_object, double.as_null_object]
      end

      it 'serializes the array of jira issues' do
        expect(subject.size).to eq(jira_issues.size)
      end
    end
  end
end
