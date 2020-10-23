# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PreventForkingHelper do
  let(:group) { create :group }
  let(:owner) { group.owner }

  it 'calls proper ability method' do
    expect(helper).to receive(:can?).with(owner, :change_prevent_group_forking, group)

    helper.can_change_prevent_forking?(owner, group)
  end
end
