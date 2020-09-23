---
stage: none
group: Style Guide
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
description: 'Writing styles, markup, formatting, and other standards for GitLab Documentation.'
---

# RESTful API

REST API resources are documented in Markdown under
[`/doc/api`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/doc/api). Each
resource has its own Markdown file, which is linked from `api_resources.md`.

When modifying the Markdown, also update the corresponding
[OpenAPI definition](https://gitlab.com/gitlab-org/gitlab/-/tree/master/doc/api/openapi)
if one exists for the resource. If not, consider creating one. Match the latest
[OpenAPI 3.0.x specification](https://swagger.io/specification/). (For more
information, see the discussion in this
[issue](https://gitlab.com/gitlab-org/gitlab/-/issues/16023#note_370901810).)

In the Markdown doc for a resource (AKA endpoint):

- Every method must have the REST API request. For example:

  ```plaintext
  GET /projects/:id/repository/branches
  ```

- Every method must have a detailed [description of the parameters](#method-description).
- Every method must have a cURL example.
- Every method must have a response body (in JSON format).

### API topic template

The following can be used as a template to get started:

````markdown
## Descriptive title

One or two sentence description of what endpoint does.

```plaintext
METHOD /endpoint
```

| Attribute   | Type     | Required | Description           |
|:------------|:---------|:---------|:----------------------|
| `attribute` | datatype | yes/no   | Detailed description. |
| `attribute` | datatype | yes/no   | Detailed description. |

Example request:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/endpoint?parameters"
```

Example response:

```json
[
  {
  }
]
```
````

### Fake user information

You may need to demonstrate an API call or a cURL command that includes the name
and email address of a user. Don't use real user information in API calls:

- **Email addresses**: Use an email address ending in `example.com`.
- **Names**: Use strings like `Example Username`. Alternatively, use diverse or
  non-gendered names with common surnames, such as `Sidney Jones`, `Zhang Wei`,
  or `Maria Garcia`.

### Fake URLs

When including sample URLs in the documentation, use:

- `example.com` when the domain name is generic.
- `gitlab.example.com` when referring to self-managed instances of GitLab.

### Fake tokens

There may be times where a token is needed to demonstrate an API call using
cURL or a variable used in CI. It is strongly advised not to use real tokens in
documentation even if the probability of a token being exploited is low.

You can use the following fake tokens as examples:

| Token type            | Token value                                                        |
|:----------------------|:-------------------------------------------------------------------|
| Private user token    | `<your_access_token>`                                              |
| Personal access token | `n671WNGecHugsdEDPsyo`                                             |
| Application ID        | `2fcb195768c39e9a94cec2c2e32c59c0aad7a3365c10892e8116b5d83d4096b6` |
| Application secret    | `04f294d1eaca42b8692017b426d53bbc8fe75f827734f0260710b83a556082df` |
| CI/CD variable        | `Li8j-mLUVA3eZYjPfd_H`                                             |
| Specific runner token | `yrnZW46BrtBFqM7xDzE7dddd`                                         |
| Shared runner token   | `6Vk7ZsosqQyfreAxXTZr`                                             |
| Trigger token         | `be20d8dcc028677c931e04f3871a9b`                                   |
| Webhook secret token  | `6XhDroRcYPM5by_h-HLY`                                             |
| Health check token    | `Tu7BgjR9qeZTEyRzGG2P`                                             |
| Request profile token | `7VgpS4Ax5utVD2esNstz`                                             |

### Method description

Use the following table headers to describe the methods. Attributes should
always be in code blocks using backticks (`` ` ``).

```markdown
| Attribute | Type | Required | Description |
|:----------|:-----|:---------|:------------|
```

Rendered example:

| Attribute | Type   | Required | Description         |
|:----------|:-------|:---------|:--------------------|
| `user`    | string | yes      | The GitLab username |

### cURL commands

- Use `https://gitlab.example.com/api/v4/` as an endpoint.
- Wherever needed use this personal access token: `<your_access_token>`.
- Always put the request first. `GET` is the default so you don't have to
  include it.
- Wrap the URL in double quotes (`"`).
- Prefer to use examples using the personal access token and don't pass data of
  username and password.

| Methods                                         | Description                                           |
|:-------------------------------------------     |:------------------------------------------------------|
| `--header "PRIVATE-TOKEN: <your_access_token>"` | Use this method as is, whenever authentication needed |
| `--request POST`                                | Use this method when creating new objects             |
| `--request PUT`                                 | Use this method when updating existing objects        |
| `--request DELETE`                              | Use this method when removing existing objects        |

### cURL Examples

The following sections include a set of [cURL](https://curl.haxx.se) examples
you can use in the API documentation.

#### Simple cURL command

Get the details of a group:

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/gitlab-org"
```

#### cURL example with parameters passed in the URL

Create a new project under the authenticated user's namespace:

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects?name=foo"
```

#### Post data using cURL's `--data`

Instead of using `--request POST` and appending the parameters to the URI, you
can use cURL's `--data` option. The example below will create a new project
`foo` under the authenticated user's namespace.

```shell
curl --data "name=foo" --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects"
```

#### Post data using JSON content

NOTE: **Note:**
In this example we create a new group. Watch carefully the single and double
quotes.

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --header "Content-Type: application/json" --data '{"path": "my-group", "name": "My group"}' "https://gitlab.example.com/api/v4/groups"
```

#### Post data using form-data

Instead of using JSON or urlencode you can use multipart/form-data which
properly handles data encoding:

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --form "title=ssh-key" --form "key=ssh-rsa AAAAB3NzaC1yc2EA..." "https://gitlab.example.com/api/v4/users/25/keys"
```

The above example is run by and administrator and will add an SSH public key
titled `ssh-key` to user's account which has an ID of 25.

#### Escape special characters

Spaces or slashes (`/`) may sometimes result to errors, thus it is recommended
to escape them when possible. In the example below we create a new issue which
contains spaces in its title. Observe how spaces are escaped using the `%20`
ASCII code.

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/42/issues?title=Hello%20Dude"
```

Use `%2F` for slashes (`/`).

#### Pass arrays to API calls

The GitLab API sometimes accepts arrays of strings or integers. For example, to
exclude specific users when requesting a list of users for a project, you would
do something like this:

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" --data "skip_users[]=<user_id>" --data "skip_users[]=<user_id>" "https://gitlab.example.com/api/v4/projects/<project_id>/users"
```

## GraphQL API

GraphQL APIs are different from [RESTful APIs](#restful-api). Reference
information is generated in our [GraphQL reference](../../api/graphql/reference/index.md).

However, it's helpful to include examples on how to use GraphQL for different
*use cases*, with samples that readers can use directly in the
[GraphiQL explorer](../api_graphql_styleguide.md#graphiql).

This section describes the steps required to add your GraphQL examples to
GitLab documentation.

### Add a dedicated GraphQL page

To create a dedicated GraphQL page, create a new `.md` file in the
`doc/api/graphql/` directory. Give that file a functional name, such as
`import_from_specific_location.md`.

### Start the page with an explanation

Include a page title that describes the GraphQL functionality in a few words,
such as:

```markdown
# Search for [substitute kind of data]
```

Describe the search. One sentence may be all you need. More information may
help readers learn how to use the example for their GitLab deployments.

### Include a procedure using the GraphiQL explorer

The GraphiQL explorer can help readers test queries with working deployments.
Set up the section with the following:

- Use the following title:

  ```markdown
  ## Set up the GraphiQL explorer
  ```

- Include a code block with the query that anyone can include in their
  instance of the GraphiQL explorer:

  ````markdown
  ```graphql
  query {
    <insert queries here>
  }
  ```
  ````

- Tell the user what to do:

  ```markdown
  1. Open the GraphiQL explorer tool in the following URL: `https://gitlab.com/-/graphql-explorer`.
  1. Paste the `query` listed above into the left window of your GraphiQL explorer tool.
  1. Select Play to get the result shown here:
  ```

- Include a screenshot of the result in the GraphiQL explorer. Follow the naming
  convention described in the [Save the image](#save-the-image) section.
- Follow up with an example of what you can do with the output. Make sure the
  example is something that readers can do on their own deployments.
- Include a link to the [GraphQL API resources](../../api/graphql/reference/index.md).

### Add the GraphQL example to the Table of Contents

You'll need to open a second MR, against the [GitLab documentation repository](https://gitlab.com/gitlab-org/gitlab-docs/).

We store our Table of Contents in the `default-nav.yaml` file, in the
`content/_data` subdirectory. You can find the GraphQL section under the
following line:

```yaml
- category_title: GraphQL
```

Be aware that CI tests for that second MR will fail with a bad link until the
main MR that adds the new GraphQL page is merged.

And that's all you need!
