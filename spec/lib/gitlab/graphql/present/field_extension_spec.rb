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

  def resolve_value
    resolve_field(field, object, current_user: user, object_type: owner)
  end

  context 'when the object does not declare a presenter' do
    it 'does not apply the extension' do
      expect(described_class).not_to receive(:new)

      expect(resolve_value).to eq 'foo'
    end
  end

  context 'when the object declare a presenter' do
    context 'when the presenter overrides the original method' do
      let(:twice) do
        Class.new do
          def initialize(object, **options)
            @object = object
          end

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
      let(:presenter) do
        Class.new do
          delegate :value, to: :object

          attr_reader :object, :options

          def initialize(object, **options)
            @object = object
            @options = options
          end

          def current_username
            "Hello #{options[:current_user]&.username} from the presenter!"
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
