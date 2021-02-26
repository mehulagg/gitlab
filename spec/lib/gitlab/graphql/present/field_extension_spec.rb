# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Graphql::Present::FieldExtension do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }

  let(:object) { double(value: 'foo') }
  let(:owner) { fresh_object_type }
  let(:field_name) { 'value' }
  let(:field) do
    ::Types::BaseField.new(name: field_name, type: GraphQL::STRING_TYPE, null: true, owner: owner)
  end

  let(:base_presenter) do
    Class.new(SimpleDelegator) do
      def initialize(object, **options)
        super(object)
        @object = object
        @options = options
      end
    end
  end

  def resolve_value
    resolve_field(field, object, current_user: user, object_type: owner)
  end

  context 'when the object does not declare a presenter' do
    it 'does not affect normal resolution' do
      expect(resolve_value).to eq 'foo'
    end
  end

  describe 'interactions with inheritance' do
    def parent
      type = fresh_object_type('Parent')
      type.present_using(provide_foo)
      type.field :foo, ::GraphQL::INT_TYPE, null: true
      type.field :value, ::GraphQL::STRING_TYPE, null: true
      type
    end

    def child
      type = Class.new(parent)
      type.graphql_name 'Child'
      type.present_using(provide_bar)
      type.field :bar, ::GraphQL::INT_TYPE, null: true
      type
    end

    def provide_foo
      Class.new(base_presenter) do
        def foo
          100
        end
      end
    end

    def provide_bar
      Class.new(base_presenter) do
        def bar
          101
        end
      end
    end

    it 'can resolve value, foo and bar' do
      type = child
      value = resolve_field(:value, object, object_type: type)
      foo = resolve_field(:foo, object, object_type: type)
      bar = resolve_field(:bar, object, object_type: type)

      expect([value, foo, bar]).to eq ['foo', 100, 101]
    end
  end

  context 'when the object declares a presenter' do
    context 'when the presenter overrides the original method' do
      def twice
        Class.new(base_presenter) do
          def value
            @object.value * 2
          end
        end
      end

      before do
        owner.present_using(twice)
      end

      it 'applies the extension, and uses the presenter method' do
        expect(described_class).to receive(:new).and_call_original

        expect(resolve_value).to eq 'foofoo'
      end
    end

    context 'when the presenter provides a new method' do
      def presenter
        Class.new(base_presenter) do
          def current_username
            "Hello #{@options[:current_user]&.username} from the presenter!"
          end
        end
      end

      before do
        owner.present_using(presenter)
      end

      context 'when we select the original field' do
        it 'is unaffected' do
          expect(resolve_value).to eq 'foo'
        end
      end

      context 'when we select the new field' do
        let(:field_name) { 'current_username' }

        it 'resolves to the presented value' do
          expect(resolve_value).to eq "Hello #{user.username} from the presenter!"
        end
      end
    end
  end
end
