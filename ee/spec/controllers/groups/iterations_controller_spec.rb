# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::IterationsController do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:iteration) { create(:iteration, group: group) }
  let_it_be(:user) { create(:user) }

  before do
    stub_licensed_features(iterations: iteration_license_available)
    group.send("add_#{role}", user) unless role == :none
    sign_in(user)
  end

  describe 'index' do
    subject { get :index, params: { group_id: group } }

    where(:iteration_license_available, :role, :status) do
      false | :developer | :not_found
      true  | :none      | :not_found
      true  | :guest     | :success
      true  | :developer | :success
    end

    with_them do
      it_behaves_like 'returning response status', params[:status]
    end
  end

  describe 'show' do
    subject { get :show, params: { group_id: group, id: iteration } }

    where(:iteration_license_available, :role, :status) do
      false | :developer | :not_found
      true  | :none      | :not_found
      true  | :guest     | :success
      true  | :developer | :success
    end

    with_them do
      it_behaves_like 'returning response status', params[:status]
    end
  end

  describe 'new' do
    subject { get :new, params: { group_id: group } }

    where(:iteration_license_available, :role, :status) do
      false | :developer | :not_found
      true  | :none      | :not_found
      true  | :guest     | :not_found
      true  | :developer | :success
    end

    with_them do
      it_behaves_like 'returning response status', params[:status]
    end
  end

  describe 'edit' do
    subject { get :edit, params: { group_id: group, id: iteration } }

    where(:iteration_license_available, :role, :status) do
      false | :developer | :not_found
      true  | :none      | :not_found
      true  | :guest     | :not_found
      true  | :developer | :success
    end

    with_them do
      it_behaves_like 'returning response status', params[:status]
    end
  end
end
