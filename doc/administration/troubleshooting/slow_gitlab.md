---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# Troubleshooting a slow GitLab installation

Sometimes you might find that GitLab is performing slower than expected. This
guide will walk you through finding the root of the slowness.

When requests are finishing slower than expected, one could say that something
(or several somethings) that helps service the request is holding/binding that
request for longer than we'd like. We need to figure out where we're "bound".

## Specific slowness

If only specific actions, projects, or pages are slow then it's usually much
easier to measure/profile and zoom in on what's causing the slowness.

Try these methods to take a closer look:

- [GitLab Performance Bar](../monitoring/performance/performance_bar.md)
- [Request Profiling](../monitoring/performance/request_profiling.md)
- Review the `*_duration` fields in the [GitLab logs](../logs.md)

## Widespread slowness

But what about if it's intermittent or more of a system-wide performance
degredation? I've found that most unexepected latency in a system is because
of a common resource being saturated and requests needing to wait on this
resource to become available.

Knowing this, it can be useful to use a resource-focused troubleshooting method like Brendan Gregg's [USE method](http://brendangregg.com/usemethod.html). See [USE Method: Linux Performance Checklist](http://brendangregg.com/USEmethod/use-linux.html) for info on using this method on a Linux system.

Other resources you should check are the web service workers (Unicorn or Puma),
the Sidekiq workers, and the `gitaly-ruby` workers. If any of these are
frequently saturated then look at scaling them if you have the headroom.

## Metrics are misleading

When trying to answer the question of "how do we measure X on a Linux system"
you'll usually end up with some sort of tool that provides you with some
metrics promising to help you understand the state of a system.

**But** it's critical to keep in mind that a metric is only a _standard of
measurement_. To successfully interpret a metric, you need to understand the
standard: how the measurement is being taken and what it means.

The standard used for a metric can change between systems and OS versions. For
example, some versions of `vmstat` would measure the `r` metric (typically
understood to be the run queue) column as `r: The number of runnable processes
(running or waiting for run time)`. But other versions of the tool report only
the actual length of the processor run _queue_.

Another good example of a commonly misunderstood metric is the linux load
average. See [Linux Load Averages: Solving the Mystery](http://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html)
for more info.

Here's a good quote from the Linux kernel's [kernel/sched/loadavg.c](https://github.com/torvalds/linux/blob/master/kernel/sched/loadavg.c):

> This file contains the magic bits required to compute the global loadavg
figure. Its a silly number but people think its important. We go through great
pains to make it work on big machines and tickless kernels.

If you keep looking, then you'll keep finding examples of metrics misleading
us. See: [CPU Utilization is Wrong](http://www.brendangregg.com/blog/2017-05-09/cpu-utilization-is-wrong.html)
and [Utilization is Virtually Useless as a Metric!](http://www.hpts.ws/papers/2007/Cockcroft_HPTS-Useless.pdf).
It's not that these metrics aren't useful barometers, but in the end any of
them can be a "silly number" if you're not careful with how you use it.

## Common Performance Problems

### Storage

Most of what GitLab does is centered around Git, which is going to rely heavily
on the performance of your Git storage. Almost everything you do in GitLab
interacts with your repos in some way, which will end up making calls to disk.

By and large, the biggest performance gains you're going to get are at the
storage layer. If you're experiencing slowness then you should try
[Filesystem Performance Benchmarking](../operations/filesystem_benchmarking.md)
and do everything in your power to make sure your IOPS are closer to SSD than spinning disks.

We also recommend against using NFS. It's slow and problematic.

### Dirty repos

Depending on your usage of a project/repo, it might hit a housekeeping edge
case where we don't automatically housekeep as well as we normally would.

You can confirm whether this is the case by using something like this
[Garbage Finder script](https://gitlab.com/-/snippets/2044873). What you're
looking for is a large number (thousands) of loose objects, loose refs, or
temp refs.