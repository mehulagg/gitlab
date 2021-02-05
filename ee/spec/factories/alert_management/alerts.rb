# frozen_string_literal: true

FactoryBot.define do
  factory :network_alert_payload, class: Hash do
    initialize_with do
      {
       fingerprint: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
       flow: {
           dropReasonDesc: "POLICY_DENIED"
        },
       ciliumNetworkPolicy: {
           kind: 'bla',
           apiVersion: 'bla',
           metadata: {
               name: 'Cilium Alert',
               generateName: 'generated NAme',
               namespace: 'LocalGitlab',
               selfLink: 'www.gitlab.com',
               uid: '2d931510-d99f-494a-8c67-87feb05e1594',
               resourceVersion: '23',
               deletionGracePeriodSeconds: 42,
               clusterName: 'TestCluster'
            },
           status: {}
        }
     }.with_indifferent_access
    end
  end
end
