## What does this MR do?

<!--

Describe in detail what your merge request does and why.

Are there any risks involved with the proposed change? What additional
test coverage is introduced to offset the risk?

Please keep this description up-to-date with any discussion that takes
place so that reviewers can understand your intent. This is especially
important if they didn't participate in the discussion.

-->

## Related Issues

<!--

Please list all related issues

-->

## Example GraphQL queries and responses

<!--

Please include examples of queries demonstrating new features
(types, fields), with example responses:

-->

Example query:

```graphql
query {
  # some query here
}
```

Example response:

```json
{
  "data": { ... }
}
```

## Does this MR meet the acceptance criteria?

### Conformity

I have:

- [ ] Added a [Changelog entry](https://docs.gitlab.com/ee/development/changelog.html).
- [ ] Added [Documentation](https://docs.gitlab.com/ee/development/documentation/workflow.html) ([if required](https://docs.gitlab.com/ee/development/documentation/workflow.html#when-documentation-is-required)).
- [ ] Read the [Code review guidelines](https://docs.gitlab.com/ee/development/code_review.html).
- [ ] Read the [Merge request performance guidelines](https://docs.gitlab.com/ee/development/merge_request_performance_guidelines.html)
- [ ] Followed the [Style guides](https://gitlab.com/gitlab-org/gitlab-ee/blob/master/doc/development/contributing/style_guides.md).
- [ ] Followed the [Database guides](https://docs.gitlab.com/ee/development/database_review.html).
- [ ] Followed the [GraphQL guides](https://docs.gitlab.com/ee/development/api_graphql_styleguide.html).
- [ ] Ensured the [Separation of EE specific content](https://docs.gitlab.com/ee/development/ee_features.html#separation-of-ee-code).

<!-- delete inapplicable items -->

### Availability and Testing

<!-- What risks does this change pose? How might it affect the quality/performance of the product?
What additional test coverage or changes to tests will be needed?
Will it require cross-browser testing?
See the test engineering process for further guidelines: https://about.gitlab.com/handbook/engineering/quality/test-engineering/ -->

<!-- If cross-browser testing is not required, please remove the relevant item, or mark it as not needed: [-] -->

I have:

- [ ] [Reviewed and added/updated tests for this feature/bug](https://docs.gitlab.com/ee/development/testing_guide/index.html).
      Consider [all test levels](https://docs.gitlab.com/ee/development/testing_guide/testing_levels.html). See the [Test Planning Process](https://about.gitlab.com/handbook/engineering/quality/test-engineering).
- [ ] [Tested this change in all supported browsers](https://docs.gitlab.com/ee/install/requirements.html#supported-web-browsers) (~frontend only).
- [ ] Informed relevant ~frontend teams to get sign-off on GraphQL structures (~backend only).
- [ ] Assessed schema changes for backwards compatibility
      (a change is not backwards compatible if any client query would need to be changed as a result).
- [ ] Included a test that requests every new field (consider using `GraphqlHelpers#all_graphql_fields_for`)
- [ ] Included tests that demonstrate new fields are not subject to N+1 performance bugs.
- [ ] Informed Infrastructure department of a default or new setting change, if applicable per [definition of done](https://docs.gitlab.com/ee/development/contributing/merge_request_workflow.html#definition-of-done)

### Security

If this MR contains changes to processing or storing of credentials or tokens, authorization and authentication methods and other items described in [the security review guidelines](https://about.gitlab.com/handbook/engineering/security/#when-to-request-a-security-review):

- [ ] Label as ~security and @ mention `@gitlab-com/gl-security/appsec`
- [ ] The MR includes necessary changes to maintain consistency between UI, API, email, or other methods
- [ ] Security reports checked/validated by a reviewer from the AppSec team

/label ~GraphQL
