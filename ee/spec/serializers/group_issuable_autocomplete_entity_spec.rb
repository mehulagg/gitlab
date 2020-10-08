# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupIssuableAutocompleteEntity do
  let(:group) { build_stubbed(:group) }
  let(:project) { build_stubbed(:project, group: group) }
  let(:issue) { build_stubbed(:issue, project: project) }
  let(:vulnerability) { build_stubbed(:vulnerability, project: project) }

  describe '#represent' do
    context 'when issuable responds to iid' do
      subject { described_class.new(issue, parent_group: group).as_json }

      it 'includes the iid, title, and reference' do
        expect(subject).to include(:iid, :title, :reference)
      end
    end

    context 'when issuable does not respond to iid' do
      subject { described_class.new(vulnerability, parent_group: project).as_json }

      it 'includes the id, title, and reference' do
        expect(subject).to include(:id, :title, :reference)
      end
    end
  end
end
