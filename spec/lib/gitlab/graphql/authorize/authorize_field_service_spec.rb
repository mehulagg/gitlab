# frozen_string_literal: true

require 'spec_helper'

# Also see spec/graphql/features/authorization_spec.rb for
# integration tests of AuthorizeFieldService
RSpec.describe Gitlab::Graphql::Authorize::AuthorizeFieldService do
  def type(type_authorizations = [])
    Class.new(Types::BaseObject) do
      graphql_name 'TestType'

      authorize type_authorizations
    end
  end

  def type_with_field(field_type, field_authorizations = [], resolved_value = 'Resolved value', **options)
    Class.new(Types::BaseObject) do
      graphql_name 'TestTypeWithField'
      options.reverse_merge!(null: true)
      field :test_field, field_type,
            authorize: field_authorizations,
            **options

      define_method :test_field do
        resolved_value
      end
    end
  end

  subject(:service) { described_class.new(field) }

  describe '#authorized_resolve' do
    let_it_be(:current_user) { build(:user) }
    let_it_be(:presented_object) { 'presented object' }
    let_it_be(:query_type) { GraphQL::ObjectType.new }
    let_it_be(:schema) { GraphQL::Schema.define(query: query_type, mutation: nil)}
    let_it_be(:query) { GraphQL::Query.new(schema, document: nil, context: {}, variables: {}) }
    let_it_be(:context) { GraphQL::Query::Context.new(query: query, values: { current_user: current_user }, object: nil) }

    let(:type_class) { type_with_field(custom_type, :read_field, presented_object) }
    let(:type_instance) { type_class.authorized_new(presented_object, context) }
    let(:field) { type_class.fields['testField'].to_graphql }

    subject(:resolved) { service.authorized_resolve.call(type_instance, {}, context)&.force }

    context 'scalar types' do
      shared_examples 'checking permissions on the presented object' do
        it 'checks the abilities on the object being presented and returns the value' do
          expected_permissions.each do |permission|
            spy_ability_check_for(permission, presented_object, passed: true)
          end

          expect(resolved).to eq('Resolved value')
        end

        it 'returns nil if the value was not authorized' do
          allow(Ability).to receive(:allowed?).and_return false

          expect(resolved).to be_nil
        end
      end

      context 'when the field is a built-in scalar type' do
        let(:type_class) { type_with_field(GraphQL::STRING_TYPE, :read_field) }
        let(:expected_permissions) { [:read_field] }

        it_behaves_like 'checking permissions on the presented object'
      end

      context 'when the field is a list of scalar types' do
        let(:type_class) { type_with_field([GraphQL::STRING_TYPE], :read_field) }
        let(:expected_permissions) { [:read_field] }

        it_behaves_like 'checking permissions on the presented object'
      end

      context 'when the field is sub-classed scalar type' do
        let(:type_class) { type_with_field(Types::TimeType, :read_field) }
        let(:expected_permissions) { [:read_field] }

        it_behaves_like 'checking permissions on the presented object'
      end

      context 'when the field is a list of sub-classed scalar types' do
        let(:type_class) { type_with_field([Types::TimeType], :read_field) }
        let(:expected_permissions) { [:read_field] }

        it_behaves_like 'checking permissions on the presented object'
      end
    end

    context 'when the field is a connection' do
      context 'when it resolves to nil' do
        let(:type_class) { type_with_field(Types::QueryType.connection_type, :read_field, nil) }

        it 'does not fail when authorizing' do
          expect(resolved).to be_nil
        end
      end
    end

    context 'when the field is a specific type' do
      let(:custom_type) { type(:read_type) }
      let(:object_in_field) { double('presented in field') }

      let(:type_class) { type_with_field(custom_type, :read_field, object_in_field) }
      let(:type_instance) { type_class.authorized_new(object_in_field, context) }

      subject(:resolved) { service.authorized_resolve.call(type_instance, {}, context) }

      it 'checks both field & type permissions' do
        spy_ability_check_for(:read_field, object_in_field, passed: true)
        spy_ability_check_for(:read_type, object_in_field, passed: true)

        expect(resolved).to eq(object_in_field)
      end

      it 'returns nil if viewing was not allowed' do
        spy_ability_check_for(:read_field, object_in_field, passed: false)
        spy_ability_check_for(:read_type, object_in_field, passed: true)

        expect(resolved).to be_nil
      end

      context 'when the field is not nullable' do
        let(:type_class) { type_with_field(custom_type, :read_field, object_in_field, null: false) }

        it 'returns nil when viewing is not allowed' do
          spy_ability_check_for(:read_type, object_in_field, passed: false)

          expect(resolved).to be_nil
        end
      end

      context 'when the field is a list' do
        let(:object_1) { double('presented in field 1') }
        let(:object_2) { double('presented in field 2') }
        let(:presented_types) { [double(object: object_1), double(object: object_2)] }

        let(:type_class) { type_with_field([custom_type], :read_field, presented_types) }
        let(:type_instance) { type_class.authorized_new(presented_types, context) }

        it 'checks all permissions' do
          allow(Ability).to receive(:allowed?) { true }

          spy_ability_check_for(:read_field, object_1, passed: true)
          spy_ability_check_for(:read_type, object_1, passed: true)
          spy_ability_check_for(:read_field, object_2, passed: true)
          spy_ability_check_for(:read_type, object_2, passed: true)

          expect(resolved).to eq(presented_types)
        end

        it 'filters out objects that the user cannot see' do
          allow(Ability).to receive(:allowed?) { true }

          spy_ability_check_for(:read_type, object_1, passed: false)

          expect(resolved.map(&:object)).to contain_exactly(object_2)
        end
      end
    end
  end

  private

  def spy_ability_check_for(ability, object, passed: true)
    expect(Ability)
      .to receive(:allowed?)
      .with(current_user, ability, object)
      .and_return(passed)
  end
end
