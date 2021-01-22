---
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: howto
---

# Reset user password

## Rake task

GitLab provides a Rake task to reset passwords of users using their usernames.
Since using this Rake task requires sudo access to the node where GitLab
application is running, this rake task by default assumes `root` as the
username, corresponding to the default admin account in a GitLab instance.

This Rake task can be invoked by the following command:

```shell
gitlab-rake "gitlab:password:reset"
```

You will be asked for password and confirmation. Upon giving matching values
for both, the password will be updated.

### Resetting password of a user other than `root`

The rake task accepts username of the user whose password should be changed, as
an argument. This can be specified as shown in the example below:

```shell
gitlab-rake "gitlab:password:reset[johndoe]"
```

## Rails console

The Rake task is capable of finding users via their usernames. However, if only
user ID or email ID of the user is known, Rails console can be used to find user
using user ID and then change password of the user manually.

1. Start a Rails console

    ```shell
    gitlab-rails console -e production
    ```

1. Find the user either by user ID or email ID

    ```ruby
    user = User.where(id: 7).first

    #or

    user = User.find_by(email: 'user@example.com')
    ```

1. Reset the password

    ```ruby
    user.password = 'secret_pass'
    user.password_confirmation = 'secret_pass'
    ```

1. When using this method instead of the [Users API](../api/users.md#user-modification),
   GitLab sends an email to the user stating that the user changed their
   password. If the password was changed by an administrator, execute the
   following command to notify the user by email:

    ```ruby
    user.send_only_admin_changed_your_password_notification!
    ```

1. Save the changes

    ```ruby
    user.save!
    ```

1. Exit the console, and then try to sign in with your new password.

NOTE:
You can also reset passwords by using the [Users API](../api/users.md#user-modification).

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
