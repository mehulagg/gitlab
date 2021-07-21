---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---
# Work Items & Work Item Types

## Problem

Issues have the potential to be a centralized hub for collaboration. We need to accept the
fact that different issue types will require different fields and different context depending
on what job they are being used to accomplish. A bug will need to list steps to reproduce. An
incident will need references to stack traces and other contextual information relevant only
to that incident. etc.

Instead of each object type diverging into a separate model, we can standardize an underlying
common model that would be customized by the attributes(called widgets further on) it encapsulates.

- Using labels to denote Issue types is cumbersome and makes every reporting view more complex.
- Issue Types are one of the top two use cases of labels, which makes it a compelling reason to
  provide a first class support for it.
- Issues are starting to feel cluttered as we add more and more capabilities to them. There
  is no consistent pattern for how to surface relationships to other objects, there is not a
  coherent interaction model across different types of issues(because we use labels for that),
  and the various implementations of issue types are feeling the pain of the lack of flexibility
  and extensibility.
- Currently Epics, Issues, Requirements, and other all have similar but just subtle enough
  differences in common interactions that it requires the user to hold a complicated mental
  model of how each behave.
- Issues are not extensible enough to support all of the emerging jobs they need to facilitate.
  Teams can create their own first-class object and use shared concerns from Issues, but this
  leads to duplicated effort and ultimately little differences between common interactions that
  lead to a less than ideal UX (see previous point/video).

## Introducing Work Item and Work Item Type terms

Instead of using `issue` or `issuable` terms to reference all types of collaboration
objects(issue, bug, feature, epic), which a lot of times creates confusion, we will be
using `work item types(WITs)` to reference all types of objects. An instance of an WIT
is a `work item(WI)`.

WI model will be built on top of current `Issue` model and we'll gradually migrate `Issue`
model code to WI model. A way to approach it would be:

```ruby
class WorkItems::WorkItem < ApplicationRecord
  self.table_name = 'issues'

  ... all the current issue.rb code
end

class Issue < WorkItems::WorkItem
  # Do not add code to this class add to WorkItems:WorkItem
end
```

Currently we already use the concept of WITs within `issues` table through `issue_type`
column. We have `issue`, `incident`, `test_case` issue types. To extend this capability
so that in future we can allow customers to define custom WITs we will be moving the
`issue_type` to a separate table `work_item_types`. The migration process of `issue_type`
to `work_item_types` would involve creating the set of WITs for all root level namespace.
Note defining an WIT would only be possible at root level namespace.

For the simplicity of it, let's say we got 3 top level namespaces with ids(1,2,3). Also say
we currently have following base types: `issue: 0`, `incident: 1`, `test_case: 2`

1. We will create `work_item_types` table and insert following records:

| namespace_id |  base_type | title     |
| -----------  | ---------- | -----     |
| 1            | 0          | Issue     |
| 1            | 1          | Incident  |
| 1            | 2          | Test Case |
| 2            | 0          | Issue     |
| 2            | 1          | Incident  |
| 2            | 2          | Test Case |
| 3            | 0          | Issue     |
| 3            | 1          | Incident  |
| 3            | 2          | Test Case |

1. To the `issues` table we will add a `work_item_type_id` column
1. Ensure we write to both `issues#issue_type` and `issues#work_item_type_id` columns for
   new or updated issues.
1. Backfill the `work_item_type_id` column to point to the `work_item_types#id` corresponding
   to issue's project root namespaces, something along the lines of:
   `issue.project.root_namespace.work_item_types.where(base_type: issue.issue_type).first.id`
1. After we have `issues#work_item_type_id` populated we can switch our queries from
   using `issue_type` to using `work_item_type_id`

For introducing a new WIT we would have 2 options:

1. Follow the first step of the above process, meaning we will need to run a migration
   that adds a new WIT for all root level namespaces, which will make the WIT available to
   all customers once the migration is run. Besides a long running migration, we'll need to
   insert a couple million records to `work_item_types`, this may be unwanted for customers
   that do not want/need additional WITs in their workflow.
1. Have an opt-in flow, so that the record in `work_item_types` for specific root namespace
   would be created only when customer opts-in. This however implies a lower discoverability
   of the newly introduced WIT.

## Work Item Types Widgets

All WITs will be sharing the same pool of predefined widgets and will be customized by
exactly which widgets are active on specific WIT. Every attribute(column or association)
will be a widget with self encapsulated functionality regardless of the WIT it belongs to.
Because any WIT can have any widget all we need to do is define which widget is active for a
specific WIT and which one is not, so when switching the type for a specific WI we would simply
display a different set of widgets.

### Widgets Metadata

In order to customize each WIT with corresponding active widgets we will need a data
structure to map each WIT to specific widgets.

**NOTE:** The exact structure of the WITs widgets metadata is to be defined.

## Custom WITs

Having the WIT widgets metadata defined and the workflow around mapping WIT to specific
widgets will enable us to expose custom WITs to the customers, so customers would be able
to create their own WITs and customize those with specific widgets from the predefined
pool of widgets.

## Custom Widgets

The end goal is to allow customers to define custom widgets and use these custom
widgets on any WIT. This however is a much further iteration and requires additional
investigation to determine both data and application architecture to be used.

## Requirements and Epics to WITs

Following the single underlying model idea and providing customisation by defining which
widgets are available to which WITs it was decided to migrate `requirements` and `epics`
into `issues` table with a predefined list of default widgets that these WITs would posses
to accomplish current feature parity with of Requirement and Epic, with the intention of
having the default set of widgets customisable in an upcoming iteration.

### Requirement to WIT

Currently `Requirement` widgets are a subset of Issue widgets, so the migration consists
mainly of data migration, keeping the backwards compatibility at API levels, and ensure
old references continue to work. The migration to a different underlying data structure
would be seamless to the end user.

### Epic to WIT

Epic on the other hand has some extra functionality that Issue WIT does not currently
have. So migrating Epic to an WIT would imply providing feature parity to all WITs. The
main missing features are ability to structure WIs into hierarchies, i.e. a hierarchy
widget and inherited date widget. In order to avoid disruption in customers workflows
that are already using `Epics`, for `Epic` migration to a WIT we will be developing a
new WIT called `Feature` that will provide feature parity with `Epic` at project level
and help provide a migration of Epic to WIT without disruptions to customers.
