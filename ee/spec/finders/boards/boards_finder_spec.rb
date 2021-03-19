# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::BoardsFinder do
  it_behaves_like 'multiple boards list service' do
    let(:parent) { create(:project, :empty_repo) }

    before do
      stub_licensed_features(multiple_group_issue_boards: true)
    end
  end

  it_behaves_like 'multiple boards list service' do
    let(:parent) { create(:group) }

    before do
      stub_licensed_features(multiple_group_issue_boards: true)
    end

    it 'returns the first issue board when multiple issue boards is disabled' do
      stub_licensed_features(multiple_group_issue_boards: false)

      expect(service.execute.size).to eq(1)
    end
  end
end
