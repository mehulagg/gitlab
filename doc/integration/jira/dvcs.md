---
stage: Create
group: Ecosystem
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Jira DVCS connector

Use the Jira DVCS (distributed version control system) connector if you self-host
your Jira instance and want to sync information to your GitLab instance. If you use
Jira Cloud and GitLab.com, use the [GitLab for Jira app](connect-app.md) unless
you have a specific need for the DVCS Connector.

When you configure the Jira DVCS connector, make sure your GitLab and Jira instances
are accessible.

- **Self-managed GitLab**: Your GitLab instance must be accessible by Jira.
- **Jira Cloud**: Your instance must be accessible through the internet.
- **Jira Server**: Your network must allow access to your instance.

## Configure a GitLab application for DVCS

We recommend you create and use a `jira` user in GitLab, and use the account only
for integration work. A separate account ensures regular account maintenance does not affect
your integration.

1. In GitLab, [create a user](../../user/profile/account/create_accounts.md) for Jira to
   use to connect to GitLab. For Jira to access all projects,
   a user with [Administrator](../../user/permissions.md) permissions must
   create the user.
1. In the top right corner, click the account's avatar, and select **Edit profile**.
1. In the left sidebar, select **Applications**.
1. In the **Name** field, enter a descriptive name for the integration, such as `Jira`.
1. In the **Redirect URI** field, enter the URI appropriate for your version of GitLab,
   replacing `<gitlab.example.com>` with your GitLab instance domain:
   - *For GitLab versions 11.3 and later,* use `https://<gitlab.example.com>/login/oauth/callback`.
     If you use GitLab.com, the URL is `https://gitlab.com/login/oauth/callback`.
   - *For GitLab versions 11.2 and earlier,* use
     `https://<gitlab.example.com>/-/jira/login/oauth/callback`.

1. For **Scopes**, select `api` and clear any other checkboxes.
1. Select **Submit**.
1. GitLab displays the generated **Application ID**
   and **Secret** values. Copy these values, as you need them to configure Jira.

## Configure Jira for DVCS

If you use Jira Cloud and GitLab.com, use the [GitLab for Jira app](connect-app.md) unless you specifically need the DVCS Connector.

1. Ensure you have completed the [GitLab configuration](#configure-a-gitlab-application-for-dvcs).
1. Go to your DVCS account:
   - *For Jira Server,* go to **Settings (gear) > Applications > DVCS accounts**.
   - *For Jira Cloud,* go to **Settings (gear) > Products > DVCS accounts**.
1. To create a new integration, select the appropriate value for **Host**:
   - *For Jira versions 8.14 and later:* Select **GitLab** or
     <!-- vale gitlab.Substitutions = NO -->
     **GitLab Self-Hosted**.
     <!-- vale gitlab.Substitutions = YES -->
   - *For Jira versions 8.13 and earlier:* Select **GitHub Enterprise**.
1. For **Team or User Account**, enter either:
   - The relative path of a top-level GitLab group that you have access to.
   - The relative path of your personal namespace.

1. In the **Host URL** field, enter the URI appropriate for your version of GitLab,
   replacing `<gitlab.example.com>` with your GitLab instance domain:
   - *For GitLab versions 11.3 and later,* use `https://<gitlab.example.com>/`.
   - *For GitLab versions 11.2 and earlier,* use
     `https://<gitlab.example.com>/-/jira`.

1. For **Client ID**, use the **Application ID** value from the previous section.

1. For **Client Secret**, use the **Secret** value from the previous section.
1. Ensure that the rest of the checkboxes are checked.
1. Select **Add** to complete and create the integration.

Jira begins to import the commits and branches for all projects in the GitLab group
you specified. This import takes a few minutes, after completed, is refreshed
every 60 minutes.

To connect additional GitLab projects from other GitLab top-level groups, or
personal namespaces, repeat the previous steps with additional Jira DVCS accounts.

After you configure the integration, read more about [how to test and use it](index.md#usage).

## Refresh data imported to Jira

Jira imports the commits and branches every 60 minutes for your projects. Real-time
integration is planned, and you can refresh the data manually from the Jira interface:

1. Sign in to your Jira instance as the user you configured the integration with.
1. Go to **Settings (gear) > Applications**.
1. Select **DVCS accounts**.
1. In the table, for the repository you want to refresh, in the **Last Activity**
   column, select the icon:
   ![Refresh GitLab information in Jira](img/jira_dev_panel_manual_refresh.png)

## Troubleshooting your DVCS connection

Refer to the items in this section if you're having problems with your DVCS connector.

### Jira cannot access GitLab server

If you complete the **Add New Account** form, authorize access, and you receive
this error, Jira and GitLab cannot connect. No other error messages
appear in any logs:

```plaintext
Error obtaining access token. Cannot access https://gitlab.example.com from Jira.
```

### SSL and TLS problems

Problems with SSL and TLS can cause this error message:

```plaintext
Error obtaining access token. Cannot access https://gitlab.example.com from Jira.
```

- The [GitLab Jira integration](../../user/project/integrations/jira.md) requires
  GitLab to connect to Jira. Any TLS issues that arise from a private certificate
  authority or self-signed certificate are resolved
  [on the GitLab server](https://docs.gitlab.com/omnibus/settings/ssl.html#other-certificate-authorities),
  as GitLab is the TLS client.
- The Jira Development panel integration requires Jira to connect to GitLab, which
  causes Jira to be the TLS client. If your GitLab server's certificate is not
  issued by a public certificate authority, the Java Truststore on Jira's server
  must have the appropriate certificate (such as your organization's
  root certificate) added to it .

Refer to Atlassian's documentation and Atlassian Support for assistance setting up Jira correctly:

- [Add a certificate](https://confluence.atlassian.com/kb/how-to-import-a-public-ssl-certificate-into-a-jvm-867025849.html)
  to the trust store.
  - The simplest approach is [`keytool`](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html).
  - Add additional roots to Java's default Truststore (`cacerts`) to allow Jira to
    also trust public certificate authorities.
  - If the integration stops working after upgrading Jira's Java runtime, the
    `cacerts` Truststore may have been replaced during the upgrade.

- Troubleshooting connectivity [up to and including TLS handshaking](https://confluence.atlassian.com/kb/unable-to-connect-to-ssl-services-due-to-pkix-path-building-failed-error-779355358.html),
  using the a java class called `SSLPoke`.
- Download the class from Atlassian's knowledge base to a directory on Jira's server, such as `/tmp`.
- Use the same Java runtime as Jira.
- Pass all networking-related parameters that Jira is called with, such as proxy
  settings or an alternative root Truststore (`-Djavax.net.ssl.trustStore`):

```shell
${JAVA_HOME}/bin/java -Djavax.net.ssl.trustStore=/var/atlassian/application-data/jira/cacerts -classpath /tmp SSLPoke gitlab.example.com 443
```

The message `Successfully connected` indicates a successful TLS handshake.

If there are problems, the Java TLS library generates errors that you can
look up for more detail.

### Scope error when connecting Jira via DVCS

```plaintext
The requested scope is invalid, unknown, or malformed.
```

Potential resolutions:

1. Verify that the URL shown in the browser after being redirected from Jira in the
   [Jira DVCS connector setup](#configure-jira-for-dvcs) includes `scope=api` in
   the query string.
1. If `scope=api` is missing from the URL, edit the
   [GitLab account configuration](#configure-a-gitlab-application-for-dvcs). Review
   the **Scopes** field and ensure the `api` check box is selected.

### Jira error adding account and no repositories listed

After you complete the **Add New Account** form in Jira and authorize access, you might
encounter these issues:

- An `Error! Failed adding the account: [Error retrieving list of repositories]` error.
- An `Account is already integrated with JIRA` error when you click **Try Again**.
- An account is visible in the DVCS accounts view, but no repositories are listed.

To resolve this issue:

- If you're using GitLab Free or GitLab Starter, be sure you're using
  GitLab 13.4 or later.
- *If you're using GitLab versions 11.10-12.7,* upgrade to GitLab 12.8.10 or later
  to resolve [an identified issue](https://gitlab.com/gitlab-org/gitlab/-/issues/37012).

[Contact GitLab Support](https://about.gitlab.com/support/) if none of these reasons apply.

### Fix synchronization issues

If Jira displays incorrect information, such as deleted branches, you may need to
resynchronize the information. To do so:

1. In Jira, go to **Jira Administration > Applications > DVCS accounts**.
1. At the account (group or subgroup) level, Jira displays an option to
   **Refresh repositories** in the **{ellipsis_h}** (ellipsis) menu.
1. For each project, there's a sync button displayed next to the **last activity** date.
   - To perform a *soft resync*, click the button.
   - To complete a *full sync*, shift-click the button.

For more information, read
[Atlassian's documentation](https://support.atlassian.com/jira-cloud-administration/docs/synchronize-jira-cloud-to-bitbucket/).
