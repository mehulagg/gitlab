## What does this MR do?

<!--
Please describe why the E2E test is being quarantined.

Please note that the aim of quarantining a test is not to get back a green pipeline, but rather to reduce 
the noise (due to constantly failing tests, flaky tests, and so on) so that new failures are not missed.
-->



### E2E Test Failure issue(s)

<!-- Please link to the respective E2E test failure issue. -->


 
### Check-list

- [ ] Follow the [Quarantining Tests guide](https://about.gitlab.com/handbook/engineering/quality/guidelines/debugging-qa-test-failures/#quarantining-tests).
- [ ] Confirm the test has a [`quarantine:` tag with the specified quarantine type](https://about.gitlab.com/handbook/engineering/quality/guidelines/debugging-qa-test-failures/#quarantined-test-types).
- [ ] Note if the test should be [quarantined for a specific environment](https://docs.gitlab.com/ee/development/testing_guide/end_to_end/environment_selection.html#quarantining-a-test-for-a-specific-environment).
- [ ] To be sure that the test is quarantined quickly, ask in the `#quality` Slack channel for someone to review and merge the merge request, rather than assigning it directly. 

<!-- Base labels. -->
/label ~"Quality" ~"QA" ~"feature" ~"feature::maintenance" 

<!-- Labels to pick into auto-deploy. -->
/label ~"Pick into auto-deploy" ~"priority::1" ~"severity::1"

<!--
Choose the stage that appears in the test path, e.g. ~"devops::create" for
`qa/specs/features/browser_ui/3_create/web_ide/add_file_template_spec.rb`.
-->
/label ~devops::

<!-- Select the current milestone. -->
/milestone %
