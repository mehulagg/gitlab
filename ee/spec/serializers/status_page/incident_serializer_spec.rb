# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StatusPage::IncidentSerializer do
  let_it_be(:issue) { create(:issue) }

  shared_examples 'valid JSON schema' do |schema:|
    it 'matches JSON schema' do
      expect(json_entity.to_json).to match_schema(schema, dir: 'ee')
    end
  end

  describe '.represent_list' do
    let(:resource) { [issue] }
    let(:json_entity) do
      subject.represent_list(resource).with_indifferent_access
    end

    it_behaves_like 'valid JSON schema', schema: 'status_page/incident_list'

    it 'returns a list with one entity' do
      expect(json_entity.size).to eq(1)
    end

    it 'does not contain comments' do
      expect(json_entity).to be_none(include(:comments))
    end
  end

  describe '.represent_details' do
    let(:resource) { issue }
    let_it_be(:user_notes) do
      create_list(:note, 1, noteable: issue, project: issue.project)
    end

    let(:json_entity) do
      subject
        .represent_details(resource, user_notes)
        .with_indifferent_access
    end

    it_behaves_like 'valid JSON schema', schema: 'status_page/incident_details'
  end
end
