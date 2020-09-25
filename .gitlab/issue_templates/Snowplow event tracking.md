<!--

* Use this issue template for creating requests to track snowplow events
* Snowplow events can be both Frontend (javascript) or Backend (Ruby)
* Snowplow is currently not used for self-hosted instances of GitLab - Self-hosted still rely on usage ping for product analytics - Snowplow is used for GitLab SaaS
* You do not need to create an issue to track generic front-end events, such as All page views, sessions, link clicks, some button clicks, etc. 
* What you should capture are specific events with defined business logic. For example, when a user creates an incident by escalating an existing alert, or when a user creates and pushes up a new Node package to the NPM registry. 

 -->

<!-- 
There are three primary fields for any event you want to track. 

1. Category is a way to group related actions together. They can also just be the GitLab category.
-->
| Category | Action | Label(s) | Feature Issue | Description | 
| ------ | ------ | ------ | ------ |
| cell | cell | cell | cell | cell |
| cell | cell | cell | cell | cell |

<!-- Inst -->
* [ ] Add front-end changes for tracking new Snowplow events
* [ ] Deploy changes to GitLab SaaS
* [ ] Verify the new Snowplow events are listed in the [Snowplow Event Exploration](https://app.periscopedata.com/app/gitlab/539181/Snowplow-Event-Exploration---last-30-days) dashboard
* [ ] Create chart(s) to track your event(s) in the relevant dashboard 
  * Use

<!--  Label reminders - you should have one of each of the following labels if you can figure out the correct ones -->
/label ~devops:: ~group: ~Category:

/label ~instrumentation ~"snowplow tracking events"