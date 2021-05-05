---
stage: Manage
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Audit Event Guide

This guide provides an overview of now Audit Event works, and how to instrument
new audit events.

## What is Audit Event?

## Audit Event schema

| attribute | type | required | description |
|-----------|------|----------| ----------- |
| name | string | false | for error tracking |
| author | User | true | |
| scope | Project/Group/User | true | |
| target | Object | true | |
| ip_address | IPAddress | false | |
| message | string | true | |

## Aduit Event instrumentation flow

We wrap the operation block in a `Gitlab::Audit::Auditor` which captures the
initial audit context (i.e. author, scope, target, ip_address) object that are
available at the time the operation is initiated.

Extra instrumentation is required in the interacted classes in the chain with
`Auditable` mixin to add audit events to the Audit Event queue via `Gitlab::Audit::EventQueue`.

The `EventQueue` are stored in Thread via `SafeRequestStore` and then later
extracted when we record an audit event in `Gitlab::Audit::Auditor`.

```plantuml
skinparam shadowing false
skinparam BoxPadding 10
skinparam ParticipantPadding 20

participant "Instrumented Class" as A
participant "Audit::Auditor" as A1 #LightBlue
participant "Audit::EventQueue" as B #LightBlue
participant "Interacted Class" as C
participant "AuditEvent" as D

A->A1: audit <b>{ block }
activate A1
A1->B: begin!
A1->C: <b>block.call
activate A1 #FFBBBB
activate C
C-->B: push [ message ]
C-->A1: true
deactivate A1
deactivate C
A1->B: read
activate A1 #FFBBBB
activate B
B-->A1: [ messages ]
deactivate B
A1->D: bulk_insert!
deactivate A1
A1->B: end!
A1-->A:
deactivate A1
```

## How to instrument new Audit Events

There are currently three ways of instrumenting audit events.

- Create a new class in `ee/lib/ee/audit/` and extend `AuditEventService`
- Call `AuditEventService` after a successful action
- Call `Gitlab::Audit::Auditor.audit` passing an action block

This inconsistency leads to unexpected bugs, increases maintain effort and worsens
developer experience. Thefore, we propose to use `Gitlab::Audit::Auditor` to
instrument new audit events.

With this new service, we can instrument audit events in two ways.

1. Using block (useful when events are emitted deep in the call stack). This
allows recording multiple audit events.

```ruby
# in the initiating service
audit_context = {
  name: 'merge_approval_rule_updated',
  author: current_user,
  scope: project_alpha,
  target: merge_approval_rule,
  ip_address: request.remote_ip
  message: 'a user has attempted to update an approval rule'
}

Gitlab::Audit::Auditor.audit(audit_context) do
  service.execute
end

# in the model
Auditable.push_audit_event('an approver has been added')
Auditable.push_audit_event('an approval group has been removed')
```

2 Using standard method call. This allows recording single audit event.

```ruby
# in the initiating service
audit_context = {
  name: 'merge_approval_rule_updated',
  author: current_user,
  scope: project_alpha,
  target: merge_approval_rule,
  ip_address: request.remote_ip
  message: 'a user has attempted to update an approval rule'
}

merge_approval_rule.save
Gitlab::Audit::Auditor.audit(audit_context)
```
