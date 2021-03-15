# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Graphql::Docs::Renderer do
  describe '#contents' do
    shared_examples 'renders correctly as GraphQL documentation' do
      it 'contains the expected section' do
        # duplicative - but much better error messages!
        section.lines.each { |line| expect(contents).to include(line) }
        expect(contents).to include(section)
      end
    end

    # Returns a Schema that uses the given `type`
    def mock_schema(type, field_description)
      query_type = Class.new(Types::BaseObject) do
        graphql_name 'Query'

        field :foo, type, null: true do
          description field_description
          argument :id, GraphQL::ID_TYPE, required: false, description: 'ID of the object.'
        end
      end

      Class.new(GraphQL::Schema) do
        query(query_type)

        def resolve_type(obj, ctx)
          raise 'Not a real schema'
        end
      end
    end

    let_it_be(:template) { Rails.root.join('lib/gitlab/graphql/docs/templates/default.md.haml') }
    let(:field_description) { 'List of objects.' }

    subject(:contents) do
      described_class.new(
        mock_schema(type, field_description),
        output_dir: nil,
        template: template
      ).contents
    end

    describe 'headings' do
      let(:type) { ::GraphQL::INT_TYPE }

      it 'contains the expected sections' do
        expect(contents.lines.map(&:chomp)).to include(
          '## `Query` type',
          '## `Mutation` type',
          '## Connections',
          '## Object types',
          '## Enumeration types',
          '## Scalar types',
          '## Abstract types',
          '### Unions',
          '### Interfaces',
          '### Input types'
        )
      end
    end

    context 'when a field has a list type' do
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

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="arraytestfoo"></a>`foo` | [`#{type_name}`](##{inner_type}) | A description. |
        DOC

        is_expected.to include(expectation)
      end

      describe 'a top level query field' do
        let(:expectation) do
          <<~DOC
            ### `Query.foo`

            List of objects.

            Returns [`ArrayTest`](#arraytest).

            #### arguments

            | Name | Type | Description |
            | ---- | ---- | ----------- |
            | <a id="queryfooid"></a>`id` | [`ID`](#id) | ID of the object. |
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

    describe 'when fields are not defined in alphabetical order' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'OrderingTest'

          field :foo, GraphQL::STRING_TYPE, null: false, description: 'A description of foo field.'
          field :bar, GraphQL::STRING_TYPE, null: false, description: 'A description of bar field.'
        end
      end

      it 'lists the fields in alphabetical order' do
        expectation = <<~DOC
          ### `OrderingTest`

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="orderingtestbar"></a>`bar` | [`String!`](#string) | A description of bar field. |
          | <a id="orderingtestfoo"></a>`foo` | [`String!`](#string) | A description of foo field. |
        DOC

        is_expected.to include(expectation)
      end
    end

    context 'when a field has a documentation reference' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'DocRefSpec'
          description 'Testing doc refs'

          field :foo,
                type: GraphQL::STRING_TYPE,
                null: false,
                description: 'The foo.',
                see: { 'A list of foos' => 'https://example.com/foos' }
          field :bar,
                type: GraphQL::STRING_TYPE,
                null: false,
                description: 'The bar.',
                see: { 'A list of bars' => 'https://example.com/bars' } do
                  argument :barity, ::GraphQL::INT_TYPE, required: false, description: '?'
                end
        end
      end

      let(:section) do
        <<~DOC
          ### `DocRefSpec`

          Testing doc refs.

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="docrefspecfoo"></a>`foo` | [`String!`](#string) | The foo. See [A list of foos](https://example.com/foos). |

          #### fields with arguments

          ##### `DocRefSpec.bar`

          The bar. See [A list of bars](https://example.com/bars).

          Returns [`String!`](#string).

          ###### arguments

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="docrefspecbarbarity"></a>`barity` | [`Int`](#int) | ?. |
        DOC
      end

      it_behaves_like 'renders correctly as GraphQL documentation'
    end

    context 'when a field is deprecated' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'DeprecatedTest'
          description 'A thing we used to use, but no longer support'

          field :foo,
                type: GraphQL::STRING_TYPE,
                null: false,
                description: 'A description.',
                deprecated: {
                  reason: 'This is deprecated',
                  milestone: '1.10'
                }
          field :foop,
                type: GraphQL::STRING_TYPE,
                null: false,
                description: 'A description.',
                deprecated: {
                  reason: 'This is deprecated',
                  replacement: 'DeprecatedTest.otherField',
                  milestone: '1.10'
                } do
                  argument :foopishness, ::GraphQL::INT_TYPE, required: false, description: '?'
                end
          field :bar,
                type: GraphQL::STRING_TYPE,
                null: false,
                description: 'A bar.',
                deprecated: {
                  reason: :renamed,
                  replacement: 'Query.foo',
                  milestone: '1.10'
                }
        end
      end

      let(:section) do
        <<~DOC
          ### `DeprecatedTest`

          A thing we used to use, but no longer support.

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="deprecatedtestbar"></a>`bar` **{warning-solid}** | [`String!`](#string) | **Deprecated** in 1.10. This was renamed. Use: [`Query.foo`](#queryfoo). |
          | <a id="deprecatedtestfoo"></a>`foo` **{warning-solid}** | [`String!`](#string) | **Deprecated** in 1.10. This is deprecated. |

          #### fields with arguments

          ##### `DeprecatedTest.foop`

          WARNING:
          **Deprecated** in 1.10.
          This is deprecated.
          Use: [`DeprecatedTest.otherField`](#deprecatedtestotherfield).

          Returns [`String!`](#string).

          ###### arguments

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="deprecatedtestfoopfoopishness"></a>`foopishness` | [`Int`](#int) | ?. |
        DOC
      end

      it_behaves_like 'renders correctly as GraphQL documentation'
    end

    context 'when a field has an Enumeration type' do
      let(:type) do
        enum_type = Class.new(Types::BaseEnum) do
          graphql_name 'MyEnum'
          description 'A test of an enum.'

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

      let(:section) do
        <<~DOC
          ### `MyEnum`

          A test of an enum.

          | Value | Description |
          | ----- | ----------- |
          | <a id="myenumbar"></a>`BAR` **{warning-solid}** | **Deprecated:** This is deprecated. Deprecated in 1.10. |
          | <a id="myenumbaz"></a>`BAZ` | A description of BAZ. |
        DOC
      end

      it_behaves_like 'renders correctly as GraphQL documentation'
    end

    context 'when a field has a global ID type' do
      let(:type) do
        Class.new(Types::BaseObject) do
          graphql_name 'IDTest'
          description 'A test for rendering IDs.'

          field :foo, ::Types::GlobalIDType[::User], null: true, description: 'A user foo.'
        end
      end

      describe 'section for IDTest' do
        let(:section) do
          <<~DOC
            ### `IDTest`

            A test for rendering IDs.

            #### fields

            | Name | Type | Description |
            | ---- | ---- | ----------- |
            | <a id="idtestfoo"></a>`foo` | [`UserID`](#userid) | A user foo. |
          DOC
        end

        it_behaves_like 'renders correctly as GraphQL documentation'
      end

      describe 'section for UserID' do
        let(:section) do
          <<~DOC
            ### `UserID`

            A `UserID` is a global ID. It is encoded as a string.

            An example `UserID` is: `"gid://gitlab/User/1"`.
          DOC
        end

        it_behaves_like 'renders correctly as GraphQL documentation'
      end
    end

    context 'when there is an interface and a union' do
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
          graphql_name 'AbstractTypeTest'
          description 'A test for abstract types.'

          field :foo, union, null: true, description: 'The foo.'
          field :flying, interface, null: true, description: 'A flying thing.'
        end
      end

      it 'lists the fields correctly, and includes descriptions of all the types' do
        type_section = <<~DOC
          ### `AbstractTypeTest`

          A test for abstract types.

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="abstracttypetestflying"></a>`flying` | [`Flying`](#flying) | A flying thing. |
          | <a id="abstracttypetestfoo"></a>`foo` | [`UserOrGroup`](#userorgroup) | The foo. |
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

          ##### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="flyingflightspeed"></a>`flightSpeed` | [`Int`](#int) | Speed in mph. |
        DOC

        implementation_section = <<~DOC
          ### `AfricanSwallow`

          A swallow from Africa.

          #### fields

          | Name | Type | Description |
          | ---- | ---- | ----------- |
          | <a id="africanswallowflightspeed"></a>`flightSpeed` | [`Int`](#int) | Speed in mph. |
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
