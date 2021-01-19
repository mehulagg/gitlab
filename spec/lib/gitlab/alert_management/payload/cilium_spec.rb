# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload::Cilium do
  let_it_be(:project) { build_stubbed(:project) }
  let(:raw_payload) {
    <<-JSON
    {
     "alert": {
         "flow": {
             "dropReasonDesc": "POLICY_DENIED"
         },
         "ciliumNetworkPolicy": {
             "kind": "bla",
             "apiVersion": "bla",
             "metadata": {
                 "name": "Cilium Alert",
                 "generateName": "generated NAme",
                 "namespace": "LocalGitlab",
                 "selfLink": "www.gitlab.com",
                 "uid": "2d931510-d99f-494a-8c67-87feb05e1594",
                 "resourceVersion": "23.",
                 "creationTimestamp": null,
                 "deletionGracePeriodSeconds": 42,
                 "clusterName": "TestCluster"
             },
             "status": {}
         }
     }
    }
    JSON
   }

  let(:parsed_payload) { described_class.new(project: project, payload: JSON.parse(raw_payload)) }

  it 'parses cilium specific fields' do
   expect(parsed_payload.title).to eq('Cilium Alert')
   expect(parsed_payload.description).to eq('POLICY_DENIED')
   expect(parsed_payload.status).to be_empty
  end
end
