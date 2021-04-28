# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::OperationsMenu do
  let(:project) { build(:project) }
  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project, show_cluster_hint: true) }

  describe 'On-call Schedules' do
    subject { described_class.new(context).items.index { |e| e.item_id == :on_call_schedules } }

    before do
      stub_licensed_features(oncall_schedules: true)
    end

    specify { is_expected.not_to be_nil }

    describe 'when the user does not have access' do
      let(:user) { nil }

      specify { is_expected.to be_nil }
    end
  end
end
