# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Epics::Update do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:epic) { create(:epic, group: group) }

  let_it_be(:user) { create(:user) }
  let_it_be(:issue) { create(:issue, project: project) }

  subject(:mutation) { described_class.new(object: group, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    subject { mutation.resolve(group_path: group.full_path, iid: epic.iid, title: 'new epic title') }

    it_behaves_like 'permission level for epic mutation is correctly verified'
  end
end
