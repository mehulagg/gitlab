# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::AutoFixService do
  describe '#execute' do
    subject { described_class.new(project).execute(ids) }

    let_it_be(:project) { create(:project) }
    let_it_be(:vulnerability_with_rem) { create(:vulnerabilities_finding_with_remediation) }

    let(:ids) { [vulnerability_with_rem.id] }

    it 'creates MR' do
      expect(MergeRequest.count).to eq(0)
      subject

      expect(MergeRequest.count).to eq(1)
    end
  end
end
