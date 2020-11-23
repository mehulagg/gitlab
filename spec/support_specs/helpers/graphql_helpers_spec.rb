# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphqlHelpers do
  include GraphqlHelpers

  # Normalize irrelevant whitespace to make comparison easier
  def norm(query)
    query.tr("\n", ' ').gsub(/\s+/, ' ').strip
  end

  describe ::GraphqlHelpers::Var do
    it 'allocates a fresh name for each var' do
      a = var('Int')
      b = var('Int')

      expect(a.name).not_to eq(b.name)
    end

    it 'can be used to construct correct signatures' do
      a = var('Int')
      b = var('String!')

      q = with_signature([a, b], '{ foo bar }')

      expect(q).to eq("query(#{a.to_graphql_value}: Int, #{b.to_graphql_value}: String!) { foo bar }")
    end

    it 'can be used to pass arguments to fields' do
      a = var('ID!')

      q = graphql_query_for(:project, { full_path: a }, :id)

      expect(norm(q)).to eq("{ project(fullPath: #{a.to_graphql_value}){ id } }")
    end

    it 'can associate values with variables' do
      a = var('Int')

      expect(a.with(3).to_h).to eq(a.name => 3)
    end

    it 'does not mutate the variable when providing a value' do
      a = var('Int')
      three = a.with(3)

      expect(three.value).to eq(3)
      expect(a.value).to be_nil
    end

    it 'can associate many values with variables' do
      a = var('Int').with(3)
      b = var('String').with('foo')

      expect(serialize_variables([a, b])).to eq({ a.name => 3, b.name => 'foo' }.to_json)
    end
  end

  describe '.query_nodes' do
    it 'can produce a basic connection selection' do
      selection = query_nodes(:users)

      expected = query_graphql_path([:users, :nodes], all_graphql_fields_for('User', max_depth: 1))

      expect(selection).to eq(expected)
    end

    it 'allows greater depth' do
      selection = query_nodes(:users, max_depth: 2)

      expected = query_graphql_path([:users, :nodes], all_graphql_fields_for('User', max_depth: 2))

      expect(selection).to eq(expected)
    end

    it 'accepts fields' do
      selection = query_nodes(:users, :id)

      expected = query_graphql_path([:users, :nodes], :id)

      expect(selection).to eq(expected)
    end

    it 'accepts arguments' do
      args = { username: 'foo' }
      selection = query_nodes(:users, args: args)

      expected = query_graphql_path([[:users, args], :nodes], all_graphql_fields_for('User', max_depth: 1))

      expect(selection).to eq(expected)
    end

    it 'accepts arguments and fields' do
      selection = query_nodes(:users, :id, args: { username: 'foo' })

      expected = query_graphql_path([[:users, { username: 'foo' }], :nodes], :id)

      expect(selection).to eq(expected)
    end

    it 'accepts explicit type name' do
      selection = query_nodes(:members, of: 'User')

      expected = query_graphql_path([:members, :nodes], all_graphql_fields_for('User', max_depth: 1))

      expect(selection).to eq(expected)
    end

    it 'can optionally provide pagination info' do
      selection = query_nodes(:users, include_pagination_info: true)

      expected = query_graphql_path([:users, "#{page_info_selection} nodes"], all_graphql_fields_for('User', max_depth: 1))

      expect(selection).to eq(expected)
    end
  end

  describe '.query_graphql_path' do
    it 'can build nested paths' do
      selection = query_graphql_path(%i[foo bar wibble_wobble], :id)

      expected = norm(<<-GQL)
      foo{
        bar{
          wibbleWobble{
            id
          }
        }
      }
      GQL

      expect(norm(selection)).to eq(expected)
    end

    it 'can insert arguments at any point' do
      selection = query_graphql_path(
        [:foo, [:bar, { quux: true }], [:wibble_wobble, { eccentricity: :HIGH }]],
        :id
      )

      expected = norm(<<-GQL)
      foo{
        bar(quux: true){
          wibbleWobble(eccentricity: HIGH){
            id
          }
        }
      }
      GQL

      expect(norm(selection)).to eq(expected)
    end
  end

  describe '.attributes_to_graphql' do
    it 'can serialize hashes to literal arguments' do
      x = var('Int')
      args = {
        an_array: [1, nil, "foo", true, [:foo, :bar]],
        a_hash: {
          nested: true,
          value: "bar"
        },
        an_int: 42,
        a_float: 0.1,
        a_string: "wibble",
        an_enum: :LOW,
        null: nil,
        a_bool: false,
        a_var: x
      }

      literal = attributes_to_graphql(args)

      expect(norm(literal)).to eq(norm(<<~EXP))
      anArray: [1,null,"foo",true,[foo,bar]],
      aHash: {nested: true, value: "bar"},
      anInt: 42,
      aFloat: 0.1,
      aString: "wibble",
      anEnum: LOW,
      null: null,
      aBool: false,
      aVar: #{x.to_graphql_value}
      EXP
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
        variables = { "updateAlertStatusInput" => { "projectPath" => "test/project" } }

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
