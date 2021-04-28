# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::EnvironmentSerializer do
  include KubernetesHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }
  let_it_be(:cluster) { create(:cluster) }

  let(:resource) { create(:environment, project: project) }

  let(:json_entity) do
    described_class.new(cluster: cluster, current_user: user)
      .represent(resource)
      .with_indifferent_access
  end

  it 'matches clusters/environment json schema' do
    expect(json_entity.to_json).to match_schema('clusters/environment', dir: 'ee')
  end
end
