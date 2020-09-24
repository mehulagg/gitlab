# frozen_string_literal: true

require "spec_helper"

RSpec.describe EE::EmailsHelper do
  describe '#action_title' do
    using RSpec::Parameterized::TableSyntax

    where(:path, :result) do
      'somedomain.com/groups/agroup/-/epics/231'     | 'View Epic'
      'somedomain.com/aproject/issues/231'           | 'View Issue'
      'somedomain.com/aproject/-/merge_requests/231' | 'View Merge request'
      'somedomain.com/aproject/-/commit/al3f231'     | 'View Commit'
    end

    with_them do
      it 'returns the expected title' do
        title = helper.action_title(path)
        expect(title).to eq(result)
      end
    end
  end
end
