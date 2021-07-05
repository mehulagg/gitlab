# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::IterationCadencesController do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:cadence) { create(:iterations_cadence, group: group) }
  let_it_be(:user) { create(:user) }

  before do
    stub_feature_flags(iteration_cadences: feature_flag_available)
    group.add_user(user, role) unless role == :none
    sign_in(user)
  end

  describe 'index' do
    subject { get :index, params: { group_id: group } }

    where(:feature_flag_available, :role, :status) do
      false | :developer | :not_found
      true  | :none      | :not_found
      true  | :guest     | :success
      true  | :developer | :success
    end

    with_them do
      it_behaves_like 'returning response status', params[:status]
    end
  end
end
