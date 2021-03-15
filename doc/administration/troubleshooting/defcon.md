---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# DEFCON

These documents a set of features that allow to disable an important parts of application
to aid in a on going application downtime.

## `ci_queueing_defcon_disable_fair_scheduling`

This feature flag if enabled temporarily disables fair scheduling on shared runners.
This can help to reduce system resource usage on `jobs/request` endpoint
by significantly reducing computations being performed.

Side effect: In case of a big backlog of jobs, the jobs will be processed in a order
they were put in a system instead of balancing the usage across many projects.

## `ci_queueing_defcon_disable_quota` **EE-only**

This feature flag if enabled temporarily disables quota validation on shared runners.
This can help to reduce system resource usage on `jobs/request` endpoint
by significantly reducing computations being performed.

Side effect: Projects which are out of quota will be run. This affects
only jobs that were created in a last hour, as prior jobs are canceled
by periodic background worker (`StuckCiJobsWorker`).
