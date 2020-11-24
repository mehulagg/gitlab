# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphqlHelpers do
  include GraphqlHelpers

  describe '.all_graphql_fields_for' do
    it 'returns a FieldSelection' do
      selection = all_graphql_fields_for('User', max_depth: 1)

      expect(selection).to be_a(::Graphql::FieldSelection)
    end

    it 'returns nil if the depth is too shallow' do
      selection = all_graphql_fields_for('User', max_depth: 0)

      expect(selection).to be_nil
    end

    it 'can select just the scalar fields' do
      selection = all_graphql_fields_for('User', max_depth: 1)

      expect(selection.paths.map(&:join))
        .to match_array(%w[avatarUrl email groupCount id location name state username webPath webUrl])
    end

    it 'selects only as far as 3 levels by default' do
      selection = all_graphql_fields_for('User')

      expect(selection.paths).to all(have_attributes(size: (be <= 3)))

      # Representative sample
      expect(selection.paths).to include(
        %w[userPermissions createSnippet],
        %w[todos nodes id],
        %w[starredProjects nodes name],
        %w[authoredMergeRequests count],
        %w[assignedMergeRequests pageInfo startCursor]
      )
    end

    it 'selects only as far as requested' do
      selection = all_graphql_fields_for('User', max_depth: 2)

      expect(selection.paths).to all(have_attributes(size: (be <= 2)))
    end

    it 'omits fields that have required arguments' do
      selection = all_graphql_fields_for('DesignCollection', max_depth: 3)

      expect(selection.paths).not_to be_empty

      expect(selection.paths).not_to include(
        %w[designAtVersion id]
      )
    end
  end

  describe '.graphql_mutation' do
    shared_examples 'correct mutation definition' do
      it 'returns correct mutation definition' do
        query = <<~MUTATION
          mutation($updateAlertStatusInput: UpdateAlertStatusInput!) {
            updateAlertStatus(input: $updateAlertStatusInput) {
              clientMutationId
            }
          }
        MUTATION
        variables = %q({"updateAlertStatusInput":{"projectPath":"test/project"}})

        is_expected.to eq(GraphqlHelpers::MutationDefinition.new(query, variables))
      end
    end

    context 'when fields argument is passed' do
      subject do
        graphql_mutation(:update_alert_status, { project_path: 'test/project' }, 'clientMutationId')
      end

      it_behaves_like 'correct mutation definition'
    end

    context 'when block is passed' do
      subject do
        graphql_mutation(:update_alert_status, { project_path: 'test/project' }) do
          'clientMutationId'
        end
      end

      it_behaves_like 'correct mutation definition'
    end

    context 'when both fields and a block are passed' do
      subject do
        graphql_mutation(:mutation_name, { variable_name: 'variable/value' }, 'fieldName') do
          'fieldName'
        end
      end

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(
          ArgumentError,
          'Please pass either `fields` parameter or a block to `#graphql_mutation`, but not both.'
        )
      end
    end
  end
end
