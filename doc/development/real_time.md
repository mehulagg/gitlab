---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Real-Time Features

This guide contains instructions on how to safely roll out new real-time 
features.

Real-time features are implemented using GraphQL Subscriptions. [Developer 
documentation](api_graphql_styleguide.md#subscriptions) is available. 

WebSockets are a relatively new technology in GitLab and supporting them at
scale introduces some challenges. For that reason, new features should be rolled 
out carefully in collaboration with the Plan and Scalability teams.

## Features reusing an existing WebSocket connection

Features reusing an existing connection incur minimal risk. Feature flag rollout
is recommended. However, it is not necessary to roll out in percentages or to
estimate new capacity required.

## Features introducing a new WebSocket connection

Any change that introduces a WebSocket connection to part of the GitLab site
incurs some scalability risk, both to nodes responsible for maintaining open 
connections and on downstream services; such as Redis and the primary database.

### Estimating peak connections

The first real-time feature to be fully enabled on GitLab.com was [real-time
assignees](https://gitlab.com/gitlab-org/gitlab/-/issues/17589). By comparing
peak throughput to the issue page against peak WebSocket connections it is
possible to crudely estimate that each 1 request per second, at peak, adds 
approximately 4200 WebSocket connections, at peak.

To understand the impact a new feature might have, sum the peak throughput (RPS) 
to the pages it will originate from (`n`) and apply the formula:

```
(n * 4200) / peak current connections
```

This calculation is crude and will need to be revised as new features are
deployed but it will yield a rough estimate of the proportion of existing
capacity that will need to be added.

### Graduated roll-out

New capacity may need to be provisioned to support your changes, depending on
current saturation and the proportion of new connections required. While
Kubernetes makes this relatively easy in most cases, there remains a risk to
downstream services.

To mitigate this, ensure that the code establishing the new WebSocket connection
is feature flagged and defaulted to 'off'. A careful, percentage-based roll-out
of the feature flag will ensure that impact can be observed on the [WebSocket
dashboard](https://dashboards.gitlab.net/d/websockets-main/websockets-overview?orgId=1)

### Backwards compatibility

For the period of the feature flag roll-out and indefinitely thereafter,
real-time features will need to be backwards compatible, or at least degrade
gracefully. Not all customers will have Action Cable enabled and further work
needs to be done before Action Cable can be enabled by default.

### Enabling Real-Time by default

Simply mounting the Action Cable library adds minimal memory footprint. However,
serving WebSocket requests introduces additional memory requirements. For this
reason, enabling Action Cable by default will require additional work; perhaps
to reduce overall memory usage, including a known issue with Workhorse, but at
least to revise Reference Architectures.

### Real-time infrastructure


