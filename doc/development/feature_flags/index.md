---
stage: none
group: Development
info: "See the Technical Writers assigned to Development Guidelines: https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments-to-development-guidelines"
---

# Feature flags in development of GitLab

**NOTE**:
The documentation below covers feature flags used by GitLab to deploy its own features, which **is not** the same
as the [feature flags offered as part of the product](../../operations/feature_flags.md).

## When to use feature flags

Developers are required to use feature flags for changes that could affect availability of existing GitLab functionality (if it only affects the new feature you're making that is probably acceptable).
Such changes include:

1. New features in high traffic areas (e.g. a new merge request widget, new option in issues/epics, new CI functionality).
1. Complex performance improvements that may require additional testing in production (e.g. rewriting complex queries, changes to frequently used API endpoints).
1. Invasive changes to the user interface (e.g. introducing a new navigation bar, removal of a sidebar, UI element change in issues or MR interface).
1. Introducing dependencies on third-party services (e.g. adding support for importing projects).
1. Changes to features that can cause data corruption or cause data loss (e.g. features processing repository data or user uploaded content).

Situations where you might consider not using a feature flag:

1. Adding a new API endpoint
1. Introducing new features in low traffic areas (e.g. adding a new export functionality in the admin area/group settings/project settings)
1. Non-invasive frontend changes (e.g. changing the color of a button, or moving a UI element in a low traffic area)

In all cases, those working on the changes should ask themselves:

> Why do I need to add a feature flag? If I don't add one, what options do I have to control the impact on application reliability, and user experience?

For perspective on why we limit our use of feature flags please see
<i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Feature flags only when needed](https://www.youtube.com/watch?v=DQaGqyolOd8).

In case you are uncertain if a feature flag is necessary, simply ask about this in an early merge request, and those reviewing the changes will likely provide you with an answer.

When using a feature flag for UI elements, make sure to _also_ use a feature
flag for the underlying backend code, if there is any. This ensures there is
absolutely no way to use the feature until it is enabled.

## How to use Feature Flags

Feature flags can be used to gradually deploy changes, regardless of whether
they are new features or performance improvements. By using feature flags,
you can determine the impact of GitLab-directed changes, while still being able
to disable those changes without having to revert an entire release.

For an overview about starting with feature flags in GitLab development,
use this [training template](https://gitlab.com/gitlab-com/www-gitlab-com/-/blob/master/.gitlab/issue_templates/feature-flag-training.md).

Before using feature flags for GitLab development, review the following development guides:

1. [Overview of the feature flag lifecycle](https://about.gitlab.com/handbook/product-development-flow/feature-flag-lifecycle/)
1. [Developing with feature flags](development.md): Learn about the types of
  feature flags, their definition and validation, how to create them, frontend and
  backend details, and other information.
1. [Documenting features deployed behind feature flags](../documentation/feature_flags.md):
  How to document features deployed behind feature flags, and how to update the
  documentation for features' flags when their states change.
1. [Controlling feature flags](controls.md): Learn the process for deploying
  a new feature, enabling it on GitLab.com, communicating the change,
  logging, and cleaning up.

User guides:

1. [How GitLab administrators can enable and disable features behind flags](../../administration/feature_flags.md):
  An explanation for GitLab administrators about how they can
  enable or disable GitLab features behind feature flags.
1. [What "features deployed behind flags" means to the GitLab user](../../user/feature_flags.md):
  An explanation for GitLab users regarding how certain features
  might not be available to them until they are enabled.

### The cost of feature flags

When reading the above, one might be tempted to think this procedure is going to
add a lot of work. Fortunately, this is not the case, and we'll show why. For
this example we'll specify the cost of the work to do as a number, ranging from
0 to infinity. The greater the number, the more expensive the work is. The cost
does _not_ translate to time, it's just a way of measuring complexity of one
change relative to another.

Let's say we are building a new feature, and we have determined that the cost of
this is 10. We have also determined that the cost of adding a feature flag check
in a variety of places is 1. If we do not use feature flags, and our feature
works as intended, our total cost is 10. This however is the best case scenario.
Optimizing for the best case scenario is guaranteed to lead to trouble, whereas
optimizing for the worst case scenario is almost always better.

To illustrate this, let's say our feature causes an outage, and there's no
immediate way to resolve it. This means we'd have to take the following steps to
resolve the outage:

1. Revert the release.
1. Perform any cleanups that might be necessary, depending on the changes that
   were made.
1. Revert the commit, ensuring the "master" branch remains stable. This is
   especially necessary if solving the problem can take days or even weeks.
1. Pick the revert commit into the appropriate stable branches, ensuring we
   don't block any future releases until the problem is resolved.

As history has shown, these steps are time consuming, complex, often involve
many developers, and worst of all: our users will have a bad experience using
GitLab.com until the problem is resolved.

Now let's say that all of this has an associated cost of 10. This means that in
the worst case scenario, which we should optimize for, our total cost is now 20.

If we had used a feature flag, things would have been very different. We don't
need to revert a release, and because feature flags are disabled by default we
don't need to revert and pick any Git commits. In fact, all we have to do is
disable the feature, and in the worst case, perform cleanup. Let's say that
the cost of this is 2. In this case, our best case cost is 11: 10 to build the
feature, and 1 to add the feature flag. The worst case cost is now 13:

- 10 to build the feature.
- 1 to add the feature flag.
- 2 to disable and clean up.

Here we can see that in the best case scenario the work necessary is only a tiny
bit more compared to not using a feature flag. Meanwhile, the process of
reverting our changes has been made significantly and reliably cheaper.

In other words, feature flags do not slow down the development process. Instead,
they speed up the process as managing incidents now becomes _much_ easier. Once
continuous deployments are easier to perform, the time to iterate on a feature
is reduced even further, as you no longer need to wait weeks before your changes
are available on GitLab.com.

### The benefits of feature flags

It may seem like feature flags are configuration, which goes against our [convention-over-configuration](https://about.gitlab.com/handbook/product/product-principles/#convention-over-configuration)
principle. However, configuration is by definition something that is user-manageable.
Feature flags are not intended to be user-editable. Instead, they are intended as a tool for Engineers
and Site Reliability Engineers to use to de-risk their changes. Feature flags are the shim that gets us
to Continuous Delivery with our monorepo and without having to deploy the entire codebase on every change.
Feature flags are created to ensure that we can safely rollout our work on our terms.
If we use Feature Flags as a configuration, we are doing it wrong and are indeed in violation of our
principles. If something needs to be configured, we should intentionally make it configuration from the
first moment.

Some of the benefits of using development-type feature flags are:

1. It enables Continuous Delivery for GitLab.com.
1. It significantly reduces Mean-Time-To-Recovery.
1. It helps engineers to monitor and reduce the impact of their changes gradually, at any scale,
   allowing us to be more metrics-driven and execute good DevOps practices, [shifting some responsibility "left"](https://devops.com/why-its-time-for-site-reliability-engineering-to-shift-left/).
1. Controlled feature rollout timing: without feature flags, we would need to wait until a specific
   deployment was complete (which at GitLab could be at any time).
1. Increased psychological safety: when a feature flag is used, an engineer has the confidence that if anything goes wrong they can quickly disable the code and minimize the impact of a change that might be risky.
1. Improved throughput: when a change is less risky because a flag exists, theoretical tests about
   scalability can potentially become unnecessary or less important. This allows an engineer to
   potentially test a feature on a small project, monitor the impact, and proceed. The alternative might
   be to build complex benchmarks locally, or on staging, or on another GitLab deployment, which has a
   large impact on the time it can take to build and release a feature.
