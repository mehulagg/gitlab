---
description: "Information on the various Internal User types found within GitLab"
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers"
type: concepts
---

# Internal Users (bots) 

GitLab uses Internal Users, or bots, to perform certain actions or functions.
These users are created as required and do not count towards a license limit.

They are used when a traditional user account would not be applicable, for example
when generating alerts or automatic review feedback.

The internal user types:

- Alert Bot
- [Ghost User](../profile/account/delete_account.md#associated-records)
- [Migration Bot](#migration-bot)
- [Support Bot](../project/service_desk.md#support-bot-user)
- Visual Review Bot

## Is a bot a User?

Yes, technically a bot is a User, but they have reduced access and a fixed purpose. None can be used for regular User 
actions, such as authentication or API requests.
They will have email addresses and names which can be attributed to any actions they perform.

## Migration Bot 

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/216120) in GitLab 13.0.

During migration to [versioned Snippets](../snippets#versioned-snippets), if a Snippet's author cannot be used for the initial repository
commit (e.g. when the author has been removed), the Migration Bot user will used instead.

For the bot:

- The name is set to  `GitLab Migration Bot`
- The email is set to `noreply+gitlab-migration-bot@{instance host}`

These details will be visible when viewing the commit history for an applicable Snippet.

