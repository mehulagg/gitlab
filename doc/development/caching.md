---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Caching Guidelines

This document describes the various caching strategies in use at GitLab, how to implement them effectively and various gotchas. This material was extracted from the excellent [Caching Workshop](https://gitlab.com/gitlab-org/create-stage/-/issues/12820).

## What is a cache?

A faster store for data

- Used in many areas of computing
  - Processors have caches, hard disks have caches, lots of things have caches!
- Often “closer” to where you want the data to finally end up
- A “simpler” store for data
- Temporary

## Why use a cache?

- To make things faster!
- To avoid IO
    - Disk reads
    - Database queries
    - Network requests
- To avoid recalculation of the same result multiple times
    - View rendering
    - JSON rendering
    - Markdown rendering
- To provide redundancy?
    - But not really
- To reduce memory consumption
    - Processing less in Ruby but just fetching big ol’ strings
- To save money
    - Especially true in cloud computing, where processors are expensive compared to RAM
    
## Doubts about caching

- Some engineers are opposed to caching except as a last resort, considering it to
be a hack, and that the real solution is to improve the underlying code to be faster
- This is could be fed by fear of cache expiry, which is understandable
- But caching is _still faster_
- You need to use both techniques to achieve true performance
  - There’s no point caching if the initial cold write is so slow it times out, for example
  - But there are few cases where caching isn’t a performance boost
- However, you can totally use caching as a quick hack, and that’s cool too
  - Sometimes the “real” fix will take months, and caching will take a day to implement
  
### Don't be afraid of caching at GitLab

Despite downsides to Redis caching, you should still feel free to make good use of the
caching setup inside the GitLab application and on gitlab.com. Our [forecasting for cache
utilisation](https://gitlab-com.gitlab.io/gl-infra/tamland/saturation.html) indicates we have plenty of headroom.



## Workflow

