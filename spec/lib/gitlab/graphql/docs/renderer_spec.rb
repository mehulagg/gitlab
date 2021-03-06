# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Graphql::Docs::Renderer do
  describe '#contents' do
    # Returns a Schema that uses the given `type`
    def mock_schema(type, field_description)
      query_type = Class.new(Types::BaseObject) do
        graphql_name 'Query'

        field :foo, type, null: true do
          description field_description
          argument :id, GraphQL::ID_TYPE, required: false, description: 'ID of the object.'
        end
      end

      GraphQL::Schema.define(
        query: query_type,
        resolve_type: ->(obj, ctx) { raise 'Not a real schema' }
      )
    end

    let_it_be(:template) { Rails.root.join('lib/gitlab/graphql/docs/templates/default.md.haml') }
    let(:field_description) { 'List of objects.' }

    let(:type) do
      Class.new(::Types::BaseObject) do
        graphql_name 'Foo'
        description 'A foo.'
        field :id, GraphQL::INT_TYPE, null: true
      end
    end

    subject(:contents) do
      described_class.new(
        mock_schema(type, field_description).graphql_definition,
        output_dir: nil,
        template: template
      ).contents
    end

    it 'contains the expected sections' do
      expect(contents.lines.map(&:chomp)).to include(
        '## `Query` type',
        '## Object types',
        '## Enumeration types',
        '## Scalar types',
        '## Abstract types',
        '### Unions',
        '### Interfaces'
      )
    end

    context 'with a field that has a [Array] return type' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'ArrayTest'

          field :foo, [GraphQL::STRING_TYPE], null: false, description: 'A description.'
        end
      end

      specify do
        type_name = '[String!]!'
        inner_type = 'string'
        expectation = <<~DOC
          ### `ArrayTest`

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `foo` | [`#{type_name}`](##{inner_type}) | A description. |
        DOC

        is_expected.to include(expectation)
      end

      context 'when generating queries section' do
        let(:expectation) do
          <<~DOC
            ### `foo`

            List of objects.

            Returns [`ArrayTest`](#arraytest)

            #### Arguments

            | Name | Type | Description |
            | ---- | ---- | ----------- |
            | `id` | [`ID`](#id) | ID of the object. |
          DOC
        end

        it 'generates the query with arguments' do
          expect(subject).to include(expectation)
        end

        context 'when description does not end with `.`' do
          let(:field_description) { 'List of objects' }

          it 'adds the `.` to the end' do
            expect(subject).to include(expectation)
          end
        end
      end
    end

    context 'with type with fields defined in reverse alphabetical order' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'OrderingTest'

          field :foo, GraphQL::STRING_TYPE, null: false, description: 'A description of foo field.'
          field :bar, GraphQL::STRING_TYPE, null: false, description: 'A description of bar field.'
        end
      end

      specify do
        expectation = <<~DOC
          ### `OrderingTest`

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `bar` | [`String!`](#string) | A description of bar field. |
          | `foo` | [`String!`](#string) | A description of foo field. |
        DOC

        is_expected.to include(expectation)
      end
    end

    context 'with a type with a deprecated field' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'DeprecatedTest'

          field :foo,
                type: GraphQL::STRING_TYPE,
                null: false,
                deprecated: { reason: 'This is deprecated', milestone: '1.10' },
                description: 'A description.'
        end
      end

      specify do
        expectation = <<~DOC
          ### `DeprecatedTest`

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `foo` **{warning-solid}** | [`String!`](#string) | **Deprecated:** This is deprecated. Deprecated in 1.10. |
        DOC

        is_expected.to include(expectation)
      end
    end

    context 'with a type with an emum field' do
      let(:type) do
        enum_type = Class.new(Types::BaseEnum) do
          graphql_name 'MyEnum'

          value 'BAZ',
                description: 'A description of BAZ.'
          value 'BAR',
                description: 'A description of BAR.',
                deprecated: { reason: 'This is deprecated', milestone: '1.10' }
        end

        Class.new(Types::BaseObject) do
          graphql_name 'EnumTest'

          field :foo, enum_type, null: false, description: 'A description of foo field.'
        end
      end

      specify do
        expectation = <<~DOC
          ### `MyEnum`

          | Value | Description |
          | ----- | ----------- |
          | `BAR` **{warning-solid}** | **Deprecated:** This is deprecated. Deprecated in 1.10. |
          | `BAZ` | A description of BAZ. |
        DOC

        is_expected.to include(expectation)
      end
    end

    context 'with a type that has a GlobalID typed field' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'IDTest'
          description 'A test for rendering IDs.'

          field :foo, ::Types::GlobalIDType[::User], null: true, description: 'A user foo.'
        end
      end

      specify do
        type_section = <<~DOC
          ### `IDTest`

          A test for rendering IDs.

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `foo` | [`UserID`](#userid) | A user foo. |
        DOC

        id_section = <<~DOC
          ### `UserID`

          Identifier of `User` objects. See GlobalID.
        DOC

        is_expected.to include(type_section)
        is_expected.to include(id_section)
      end
    end

    context 'when there is an interace and a union' do
      let(:type) do
        user = Class.new(::Types::BaseObject)
        user.graphql_name 'User'
        user.field :user_field, ::GraphQL::STRING_TYPE, null: true
        group = Class.new(::Types::BaseObject)
        group.graphql_name 'Group'
        group.field :group_field, ::GraphQL::STRING_TYPE, null: true

        union = Class.new(::Types::BaseUnion)
        union.graphql_name 'UserOrGroup'
        union.description 'Either a user or a group.'
        union.possible_types user, group

        interface = Module.new
        interface.include(::Types::BaseInterface)
        interface.graphql_name 'Flying'
        interface.description 'Something that can fly.'
        interface.field :flight_speed, GraphQL::INT_TYPE, null: true, description: 'Speed in mph.'

        african_swallow = Class.new(::Types::BaseObject)
        african_swallow.graphql_name 'AfricanSwallow'
        african_swallow.description 'A swallow from Africa.'
        african_swallow.implements interface
        interface.orphan_types african_swallow

        Class.new(::Types::BaseObject) do
          graphql_name 'AbstactTypeTest'
          description 'A test for abstract types.'

          field :foo, union, null: true, description: 'The foo.'
          field :flying, interface, null: true, description: 'A flying thing.'
        end
      end

      specify do
        type_section = <<~DOC
          ### `AbstactTypeTest`

          A test for abstract types.

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `flying` | [`Flying`](#flying) | A flying thing. |
          | `foo` | [`UserOrGroup`](#userorgroup) | The foo. |
        DOC

        union_section = <<~DOC
          #### `UserOrGroup`

          Either a user or a group.

          One of:

          - [`Group`](#group)
          - [`User`](#user)
        DOC

        interface_section = <<~DOC
          #### `Flying`

          Something that can fly.

          Implementations:

          - [`AfricanSwallow`](#africanswallow)

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `flightSpeed` | [`Int`](#int) | Speed in mph. |
        DOC

        implementation_section = <<~DOC
          ### `AfricanSwallow`

          A swallow from Africa.

          | Field | Type | Description |
          | ----- | ---- | ----------- |
          | `flightSpeed` | [`Int`](#int) | Speed in mph. |
        DOC

        is_expected.to include(
          type_section,
          union_section,
          interface_section,
          implementation_section
        )
      end
    end
  end
end
