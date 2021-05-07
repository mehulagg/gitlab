# frozen_string_literal: true

require 'spec_helper'

# There must be a method or let called `mutation` defined that executes
# the mutation and one called `mutation_name` that is the name of the
# mutation being executed.
RSpec.shared_examples 'an on-demand scan mutation when user cannot run an on-demand scan' do
  let(:project) { create(:project, :repository, creator: current_user) }
  let(:current_user) { create(:user) }
  let(:full_path) { project.full_path }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when a user does not have access to the project' do
    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'when a user does not have access to run a dast scan on the project' do
    before do
      project.add_guest(current_user)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end
end
