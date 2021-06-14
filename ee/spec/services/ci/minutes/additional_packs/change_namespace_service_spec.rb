# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::AdditionalPacks::ChangeNamespaceService do
  describe '#execute' do
    let_it_be(:namespace) { create(:group) }
    let_it_be(:existing_packs) { create_list(:ci_minutes_additional_pack, 5, namespace: namespace) }
    let_it_be(:target) { create(:group, owner: namespace.owner) }
    let_it_be(:subgroup) { build(:group, :nested) }
    let_it_be(:admin) { build(:user, :admin) }
    let_it_be(:non_admin) { build(:user) }

    subject(:change_namespace) { described_class.new(user, namespace, target).execute }

    context 'with a non-admin user' do
      let(:user) { non_admin }

      it 'raises an error' do
        expect { change_namespace }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end

    context 'with an admin user' do
      let(:user) { admin }

      context 'with valid namespace and target namespace' do
        it 'moves all existing packs to the target namespace', :aggregate_failures do
          expect(target.ci_minutes_additional_packs).to be_empty

          change_namespace

          expect(target.ci_minutes_additional_packs).to match_array(existing_packs)
          expect(existing_packs.first.reload.namespace).to eq target
        end
      end

      context 'with invalid namespace' do
        let(:namespace) { subgroup }

        it 'returns an error' do
          expect(change_namespace[:status]).to eq :error
          expect(change_namespace[:message]).to eq 'Namespace must be a root namespace'
        end
      end

      context 'when the target namespace is not a root namespace' do
        let(:target) { subgroup }

        it 'returns an error' do
          expect(change_namespace[:status]).to eq :error
          expect(change_namespace[:message]).to eq 'Target namespace must be a root namespace'
        end
      end

      context 'when the target namespace is owned by another user' do
        let(:target) { build(:group, owner: non_admin) }

        it 'returns an error' do
          expect(change_namespace[:status]).to eq :error
          expect(change_namespace[:message]).to eq 'Target namespace must belong to the same owner'
        end
      end

      context 'when updating packs fails' do
        it 'rolls back updates for all packs' do
          allow_next_instance_of(described_class) do |instance|
            allow(instance).to receive(:success).and_raise(StandardError)
          end

          expect { change_namespace }.to raise_error(StandardError)
          expect(namespace.ci_minutes_additional_packs.count).to eq 5
          expect(target.ci_minutes_additional_packs.count).to eq 0
        end
      end
    end
  end
end
