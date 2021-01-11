---
comments: false
description: 'Database Testing'
---

# Database Testing

We have identified [common themes of reverted migrations](https://gitlab.com/gitlab-org/gitlab/-/issues/233391) and discovered failed migrations breaking in both production and staging even when successfully tested in a developer environment. We have also experienced production incidents even with successful testing in staging. These failures are quite expensive: they can have a significant effect on availability, block deployments, and generate incident escalations. These escalations must be triaged and either reverted or fixed forward. Often, this can take place without the original author's involvement due to time zones and/or the criticality of the escalation. With our increased deployment speeds and stricter uptime requirements, the need for improving database testing is critical, particularly earlier in the development process (shift left).

From a developer's perspective, it is hard if not unfeasible to validate a migration on a large enough dataset before it goes into production.

Our primary goal is to **provide developers with immediate feedback for new migrations and other database-related changes tested on a full copy of the production database**, and to do so with high levels of efficiency (particularly in terms of infrastructure costs).

## Current day

Developers are expected to test database migrations prior to deploying to any environment, but we lack the ability to perform testing against large environments such as GitLab.com. The [developer database migration style guide](/ee/development/migration_style_guide.md) provides guidelines on migrations, and we focus on validating migrations during code review and testing in CI and staging.

The [code review phase](/ee/development/database_review.html) involves Database Reviewers and Maintainers to manually check the migrations committed. This often involves knowing and spotting problematic patterns and their particular behavior on GitLab.com from experience. There is no large-scale environment available that allows us to test database migrations before they are being merged.

Testing in CI is done on a very small database. We mainly check forward/backward migration consistency, evaluate rubocop rules to detect well-known problematic behaviors (static code checking) and have a few other, rather technical checks in place (adding the right files etc).

Once merged, migrations are being deployed to the staging environment. Its database size is less than 5% of the production database size as of January 2021 and its recent data distribution does not resemble the production site. Oftentimes, we see migrations succeed in staging but then fail in production due to query timeouts or other unexpected problems.

Today, we have gained experience with working on a thin-cloned production database (more on this below) and already use it to provide developers with access to production query plans, automated query feedback and suggestions with optimizations. This is built around [Database Labs](https://gitlab.com/postgres-ai/database-lab) and [Joe](https://gitlab.com/postgres-ai/joe) and available through Slack (using chatops) and [postgres.ai](https://postgres.ai/).

## Vision

As a developer, I am working on a GitLab code change that includes a data migration and changes a heavy database query. I push my code and create a Merge Request from it and provide an example query in the description. The pipeline executes the data migration and examines the query in a large-scale environment (a copy of GitLab.com). Once the pipeline finishes, the Merge Request gets detailed feedback and information about the migration and the query I provided. This is based on a full clone of the production database with a state that is very close to production (minutes).

For database migrations, the information gathered from execution on the clone includes

1. Overall runtime
1. Detailed statistics for queries being executed in the migration (normalizing queries and showing their frequencies and execution times, perhaps plotted)
1. Dangerous locks held during the migration (which would cause blocking situations in production)

For database queries, we can automatically gather

1. Query plans along with visualization
1. Execution times and predictions for production
1. Suggestions on optimizations from Joe
1. Memory and IO statistics

After having gotten that feedback, I go back and investigate a performance problem with the data migration. Once I have a fix pushed, I can repeat the above cycle and eventually send my Merge Request to review from a Database Reviewer and later a Database Maintainer.

This information gathering is done in a protected and safe environment, making sure that there is no unauthorized access to production data and we can safely execute code in this environment.

The intended benefits include

1. Shifting left: Allow developers to understand large-scale database performance and what to expect to happen on GitLab.com in a self-service manner
1. Automate the information gathering phase to make it easier for everybody involved in code review (developer, reviewer, maintainer) by providing relevant details automatically and upfront.

## Technology and Next Steps

We already use Database Labs from postgres.ai, which is a thin-cloning technology. We maintain a Postgres replica which is up to date with production data but does not serve any production traffic. This runs Database Labs which allows us to quickly create a full clone of the production dataset (in the order of seconds).

Internally, this is based on ZFS and implements a "thin-cloning technology". That is, ZFS snapshots are being used to clone the data and it exposes a full read/write Postgres cluster based on the cloned data. This is called a *thin clone*. It is rather short lived and is going to be destroyed again shortly after we are finished using it.

It is important to note that a thin clone is fully read/write. This allows us to execute migrations on top of it.

Database Labs provides a API we can interact with to manage thin clones. In order to automate the migration and query testing, we add steps to the `gitlab/gitlab-org` CI pipeline. This triggers automation that performs the following steps for a given Merge Request:

1. Create a thin-clone with production data for this testing session
1. Pull GitLab code from the Merge Request
1. Execute migrations and gather all necessary information from it
1. Execute query testing and gather all necessary information from it
1. Post back the results of the migration and query testing to the Merge Request
1. Destroy the thin-clone

### Short-term

The short-term focus is on migration testing and using the existing Database Labs instance from postgres.ai for it.

We implement a secured CI pipeline on ops.gitlab.net that adds the execution steps outlined above. The goal is to secure this pipeline in order to solve the following problem:

1. Make sure we strongly protect production data, even though we
1. allow everyone (GitLab team/developers) to execute arbitrary code on the thin-clone which contains production data.

This is in principle achieved by locking down the GitLab Runner instance executing the code and its containers on a network level, such that no data can escape over the network. We make sure no communication can happen to the outside world from within the container executing the GitLab Rails code (and its database migrations).

Furthermore, we limit the ability to view the results of the jobs (including the output printed from code) to Maintainer and Owner level on the ops.gitlab.net pipeline.

With this step implemented, we already have the ability to execute database migrations on the thin-cloned GitLab.com database automatically from GitLab CI and provide feedback back to the Merge Request and developer. The content of that feedback is expected to evolve over time and we can continously add to this.

We already have a [MVC-style implementation for the pipeline](https://gitlab.com/gitlab-org/database-team/gitlab-com-migrations) for reference and an [example Merge Request with feedback](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/50793#note_477815261) from the pipeline.

The short-term goal is detailed in [this epic](https://gitlab.com/groups/gitlab-org/database-team/-/epics/6).

### Mid-term

Mid-term, we plan to expand the level of detail the testing pipeline reports back to the Merge Request and expand its scope to cover query testing as described above, too.

By doing so, we use our experience from database code reviews and using thin-clone technology and bring this back closer to the GitLab workflow. Instead of reaching out to different tools (postgres.ai, joe, Slack, plan visualizations etc.) we bring this back to GitLab and working directly on the Merge Request.

There are opportunities to discuss for extracting features from this into GitLab itself. For example, annotating the Merge Request with query examples and attaching feedback gathered from the testing run can become a first-class citizen instead of using Merge Request description and comments for it.

### Long-term

Long-term, we envision using thin-clones to fully test application changes before they are being merged - providing developers with good confidence about deploying to a large-scale environment like GitLab.com. We are going to add high-quality details that allow us to ship application changes to our large-scale environment with confidence.

In order to bring down licensing cost in the long run, we strive to move towards either using Database Labs Community Edition for thin-cloning or building our own solution.

## An alternative discussed: Anonymization

At the core of this problem lies the concern about executing (potentially arbitrary) code on a production dataset and making sure the production data is well protected. The approach discussed above solves this by strongly limiting access to the output of said code.

An alternative approach we have discussed and abandoned is to "scrub" and anonymize production data. The idea is to remove any sensitive data from the database and use the resulting dataset for database testing. This has a lot of downsides which led us to abandon the idea:

1. Anonymization is complex by nature - it is a hard problem to call a "scrubbed clone" actually safe to work with in public
1. Annotating data as "sensitive" is error prone
1. Scrubbing not only removes sensitive data, but also changes data distribution - which greatly affects performance of migrations and queries
1. Scrubbing heavily changes the database contents, potentially updating a lot of data - which leads to different data storage details (think MVCC bloat), affecting performance of migrations and queries

## Who

This effort is owned and driven by the [GitLab Database Team](https://about.gitlab.com/handbook/engineering/development/enablement/database/) with support from the [GitLab.com Reliability Datastores](https://about.gitlab.com/handbook/engineering/infrastructure/team/reliability/datastores/) team.

<!-- vale gitlab.Spelling = NO -->

| Role                         | Who
|------------------------------|-------------------------|
| Author                       |    Andreas Brandl       |
| Architecture Evolution Coach | Gerardo Lopez-Fernandez |
| Engineering Leader           |    Craig Gomes          |
| Domain Expert                |    Yannis Roussos       |
| Domain Expert                |    Pat Bair             |
| Domain Expert                |    (tbd)                |

DRIs:

| Role                         | Who
|------------------------------|------------------------|
| Product                      |    Fabian Zimmer       |
| Leadership                   |    Craig Gomes         |
| Engineering                  |    Andreas Brandl      |

<!-- vale gitlab.Spelling = YES -->
