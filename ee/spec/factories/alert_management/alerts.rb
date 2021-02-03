# frozen_string_literal: true

FactoryBot.define do
  factory :network_alert_payload, class: Hash do
    initialize_with do
      {
        flow: {
          time: '2021-02-02T18:04:21.213587449Z',
          verdict: 'POLICY_DENIED',
          dropReasonDesc: 123,
          ethernet: { source: '56:b6:52:62:6b:68', destination: '3a:dc:e3:9a:55:11' },
          IP: { source: '10.0.0.224', destination: '10.0.0.87', ipVersion: 'IPv4' },
          l4: { TCP: { sourcePort: 38_794, destinationPort: 5000, flags: { SYN: nil } } },
          source: {
            ID: 799,
            identity: 37_570,
            namespace: 'gitlab-managed-apps',
            labels: [
              'k8s:app.kubernetes.io/component=controller',
              'k8s:app=nginx-ingress'
            ],
            podName: 'ingress-nginx-ingress-controller-7dd4d7474d-m95gd'
          },
          destination: {
            ID: 259,
            identity: 30_147,
            namespace: 'agent-project-21-production',
            labels: [
              'k8s:app=production',
              'k8s:io.cilium.k8s.namespace.labels.app.gitlab.com/app=root-agent-project'
            ],
            podName: 'production-7b998ffb56-vvl68'
          },
          Type: 'L3_L4',
          nodeName: 'minikube',
          eventType: { type: 5 },
          trafficDirection: 'INGRESS',
          Summary: 'TCP Flags: SYN'
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
