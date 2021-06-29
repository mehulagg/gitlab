# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Ci::Runner::Update do
  include GraphqlHelpers

  let_it_be(:runner) do
    create(:ci_runner, active: true, locked: false, run_untagged: true, public_projects_minutes_cost_factor: 0.0,
      private_projects_minutes_cost_factor: 0.0)
  end

  let(:mutation) { described_class.new(object: nil, context: current_ctx, field: nil) }

  subject { mutation.resolve(id: runner.to_global_id, **mutation_params) }

  before do
    subject
    runner.reload
  end

  describe '#resolve' do
    context 'when user can update runner', :enable_admin_mode do
      let_it_be(:admin_user) { create(:user, :admin) }

      let(:current_ctx) { { current_user: admin_user } }

      context 'when mutation includes cost factor arguments' do
        let(:mutation_params) do
          {
            public_projects_minutes_cost_factor: 2.5,
            private_projects_minutes_cost_factor: 0.5
          }
        end

        it 'updates public_projects_minutes_cost_factor to 2.5' do
          expect(runner.public_projects_minutes_cost_factor).to eq(2.5)
        end

        it 'updates private_projects_minutes_cost_factor to 0.5' do
          expect(runner.private_projects_minutes_cost_factor).to eq(0.5)
        end
      end
    end
  end
end
