---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# Resource visibility

GitLab provides access to different resources depending on configuration.

## Project visibility

GitLab allows [Owners](../user/permissions.md) to set a project's visibility as:

- **Public**
- **Internal**
- **Private**

These visibility levels affect who can see the project in the public access directory (`/public`
for your GitLab instance). For example, <https://gitlab.com/public>.

### Public projects

Public projects can be cloned **without any** authentication over HTTPS.

They are listed in the public access directory (`/public`) for all users.

**Any signed-in user** has the [Guest role](../user/permissions.md) on the repository.

### Internal projects

Internal projects can be cloned by any signed-in user except
[external users](../user/permissions.md#external-users).

They are also listed in the public access directory (`/public`), but only for signed-in users.

Any signed-in users except [external users](../user/permissions.md#external-users) have the
[Guest role](../user/permissions.md) on the repository.

NOTE:
From July 2019, the `Internal` visibility setting is disabled for new projects, groups,
and snippets on GitLab.com. Existing projects, groups, and snippets using the `Internal`
visibility setting keep this setting. You can read more about the change in the
[relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/12388).

### Private projects

Private projects can only be cloned and viewed by project members (except for guests).

They appear in the public access directory (`/public`) for project members only.

### Change project visibility

1. Go to your project's **Settings**.
1. Change **Visibility Level** to either Public, Internal, or Private.

## Group visibility

Like projects, a group can be configured to limit the visibility of it to:

- Anonymous users.
- All signed-in users.
- Only explicit group members.

The restriction for visibility levels on the application setting level also applies to groups. If
set to internal, the explore page is empty for anonymous users. The group page has a visibility
level icon.

Administrator users cannot create subgroups or projects with higher visibility level than that of
the immediate parent group.

## User visibility

The public page of a user, located at `/username`, is always visible whether you are signed-in or
not.

When visiting the public page of a user, you can only see the projects which you have privileges to.

If the public level is restricted, user profiles are only visible to signed-in users.

## Page visibility

By default, the following directories are visible to unauthenticated users:

- Public access (`/public`).
- Explore (`/explore`).
- Help (`/help`).

However, if the access level of the `/public` directory is restricted, these directories are visible
only to signed-in users.

## Restrict use of public or internal projects

You can restrict the use of visibility levels for users when they create a project or a snippet.
This is useful to prevent users from publicly exposing their repositories by accident. The
restricted visibility settings do not apply to admin users.

For details, see [Restricted visibility levels](../user/admin_area/settings/visibility_and_access_controls.md#restricted-visibility-levels).

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
