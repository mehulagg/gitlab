# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::BaseArgument do
  let_it_be(:field) do
    Types::BaseField.new(name: 'field', type: GraphQL::STRING_TYPE, null: true)
  end

  it_behaves_like 'a GraphQL field or argument that checks feature flag visibility' do
    subject { described_class.new(name: 'test', type: GraphQL::STRING_TYPE, feature_flag: flag, description: 'Test description.', required: false, owner: field) }
  end

  include_examples 'Gitlab-style deprecations' do
    let(:base_args) { { name: 'test', type: GraphQL::STRING_TYPE, required: false, owner: field } }

    def subject(args = {})
      described_class.new(**base_args.merge(args))
    end
  end
end
