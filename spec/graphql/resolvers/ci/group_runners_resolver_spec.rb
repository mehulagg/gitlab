# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::GroupRunnersResolver do
  include GraphqlHelpers

  include_context 'runners resolver setup'

  it_behaves_like Resolvers::Ci::GroupRunnersResolver

  describe '#resolve' do
    subject { resolve(described_class, obj: group, ctx: { current_user: user }, args: args).items.to_a }

    context 'with user as group owner' do
      before do
        group.add_owner(user)
      end

      context 'with a membership argument' do
        context "set to :direct" do
          let(:args) do
            { membership: :direct }
          end

          it { is_expected.to eq([group_runner]) }
        end

        context "set to :descendants" do
          let(:args) do
            { membership: :descendants }
          end

          it { is_expected.to eq([group_runner, offline_project_runner, inactive_project_runner]) }
        end
      end
    end

    context 'with a membership argument' do
      context "set to :direct" do
        let(:args) do
          { membership: :direct }
        end

        it { is_expected.to eq([]) }
      end

      context "set to :descendants" do
        let(:args) do
          { membership: :descendants }
        end

        it { is_expected.to eq([]) }
      end
    end
  end
end
