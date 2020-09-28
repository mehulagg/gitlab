<!--
* Use this issue template for creating requests to track snowplow events
* Snowplow events can be both Frontend (javascript) or Backend (Ruby)
* Snowplow is currently not used for self-hosted instances of GitLab - Self-hosted still rely on usage ping for product analytics - Snowplow is used for GitLab SaaS
* You do not need to create an issue to track generic front-end events, such as All page views, sessions, link clicks, some button clicks, etc.
* What you should capture are specific events with defined business logic. For example, when a user creates an incident by escalating an existing alert, or when a user creates and pushes up a new Node package to the NPM registry.
 -->

<!--
We generally recommend events be tracked using a [structured event](https://docs.snowplowanalytics.com/docs/understanding-tracking-design/out-of-the-box-vs-custom-events-and-entities/#structured-events) which has 5 properties you can use. There may be instances where structured events are not sufficient. You may want to track an event where the property changes frequently or is general something very unique. In those cases, use a [self-decribing event](https://docs.snowplowanalytics.com/docs/understanding-tracking-design/out-of-the-box-vs-custom-events-and-entities/#self-describing-events)

-->

## Structured Snowplow events to track

* Category: The name for the group of objects you want to track. They can just be the GitLab category, or a specific workflow within a category.
* Action: A string that is used to define the user action.
* Label: Optional. The specific element, or object that's being acted on. This is either the label of the element (e.g. a tab labeled 'Create from template' may be `create_from_template`) or a unique identifier if no text is available (e.g. closing the Groups dropdown in the top navbar might be `groups_dropdown_close`), or it could be the name or title attribute of a record being created.
* Property: Optional. Any additional property of the element, or object being acted on.
* Value: Optional, numeric. Describes a numeric value or something directly related to the event. This could be the value of an input (e.g. `10` when clicking `internal` visibility)

| Category | Action | Label | Property | Feature Issue | Additional Information |
| ------ | ------ | ------ | ------ | ------ | ------ |
| cell | cell | cell | cell | cell | cell |
| cell | cell | cell | cell | cell | cell |

<!--
  Snowplow event tracking starts with instrumentation and completed after a chart is created in Sisense.

  Use this checklist to ensure all steps are completed
-->

## Snowplow event tracking checklist
* [ ] Engineering complete work and deploy changes to GitLab SaaS
* [ ] Verify the new Snowplow events are listed in the [Snowplow Event Exploration](https://app.periscopedata.com/app/gitlab/539181/Snowplow-Event-Exploration---last-30-days) dashboard
* [ ] Create chart(s) to track your event(s) in the relevant dashboard
  * [ ] Use the [Chart Snowplow Actions](https://app.periscopedata.com/app/gitlab/snippet/Chart-Snowplow-Actions/5546da87ae2c4a3fbc98415c88b3eedd/edit) SQL snippet to quickly visualize usage. See [example](https://app.periscopedata.com/app/gitlab/737489/Health-Group-Dashboard?widget=9797112&udv=0)

<!--  Label reminders - you should have one of each of the following labels if you can figure out the correct ones -->
/label ~devops:: ~group: ~Category:
/label ~"snowplow tracking events"
