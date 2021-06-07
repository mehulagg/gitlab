---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Custom Emoji API

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/37911) in GitLab 13.6
> - It's [deployed behind a feature flag](../user/feature_flags.md), disabled by default.

Custom emoji can be added to a group using GraphQL API. After adding, they can be used in comments/descriptions.

We can use the following GraphQL API to add and retrieve custom emojis in a group.

Parameters:

| Attribute  	| Type 			 	| Required 	| Description 																|
|:--------------|:------------------|:----------|:--------------------------------------------------------------------------|
| `group_path`	| integer/string 	| yes 		| ID or [URL-encoded path of the group](README.md#namespaced-path-encoding)	|
| `name`	 	| string 		 	| yes 		| Name of the custom emoji. |
| `file`	 	| string 		 	| yes 		| URL of the custom emoji image. |

## Create a custom emoji

```graphql
mutation CreateCustomEmoji($groupPath: ID!) {
  createCustomEmoji(input: {groupPath: $groupPath, name: "party-parrot", file: "https://cultofthepartyparrot.com/parrots/hd/parrot.gif", external: true}) {
    clientMutationId
    name
    errors
  }
}
```

## Get custom emoji for a group

```graphql
query GetCustomEmoji($groupPath: ID!) {
  group(fullPath: $groupPath) {
    id
    customEmoji {
      nodes {
        name
      }
    }
  }
}
```
