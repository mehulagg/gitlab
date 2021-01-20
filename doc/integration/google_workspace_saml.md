---
type: reference
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Google Workspace SSO provider

Google Workspace (formerly G Suite) is a [Single Sign-on provider](https://support.google.com/a/answer/60224?hl=en) that can be used to authenticate
with GitLab.

The following documentation enables Google Workspace as a SAML provider for GitLab.

## Configure the Google Workspace SAML app

The following guidance is based on this Google Workspace article, on how to [Set up your own custom SAML application](https://support.google.com/a/answer/6087519?hl=en):

1. On the [Google Workspace Admin Console](https://admin.google.com), go to **Apps > SAML apps**.
1. Click on the **Add App** dropdown and select **Add custom SAML app**.
1. On the **App details** page, enter a name for the SAML app eg. *GitLab* and click **Continue**.
1. On the **Google Identity Provider details** page, complete the following and then click **Continue**.
    - Make a note of the **SSO URL** as you will need this when configuring the `idp_sso_target_url` setting in GitLab.
    - Download a copy of the **Certificate** as you will need this for the `idp_certificate_fingerprint` setting in GitLab.
1. On the **Service provider details** page, configure the following and then click **Continue**.
    - **ACS URL** should be `https://<GITLAB_DOMAIN>/users/auth/saml/callback`
    - **Entity ID** must be a value unique to your SAML app - but you could use `https://<GITLAB_DOMAIN>` for example. Make a note of the **Entity ID** as you will need this for the `issuer` setting in GitLab.
    - **Name ID format** should be *EMAIL*
    - **Name ID** should be *Basic Information > Primary email*
1. On the **Attributes** page, add the following mappings and then click **Finish**.

    | Google Directory attributes | App attributes |
    | :-------------------------- |:---------------|
    | First name                  | `first_name`   |
    | Last name                   | `last_name`    |
    | Primary email               | `email`        |

---

Now that the Google Workspace SAML app is configured, it's time to enable it in GitLab.

## Configure GitLab

1. See [Initial OmniAuth Configuration](../integration/omniauth.md#initial-omniauth-configuration)
   for initial settings.

1. To allow your users to use Google Workspace to sign up without having to manually create
   an account first, don't forget to add the following values to your
   configuration:

   **For Omnibus GitLab installations**

   Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
   gitlab_rails['omniauth_block_auto_created_users'] = false
   ```

   ---

   **For installations from source**

   Edit `config/gitlab.yml`:

   ```yaml
   allow_single_sign_on: ["saml"]
   block_auto_created_users: false
   ```

1. You can also automatically link Google Workspace users with existing GitLab users if
   their email addresses match by adding the following setting:

   **For Omnibus GitLab installations**

   Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['omniauth_auto_link_saml_user'] = true
   ```

   ---

   **For installations from source**

   Edit `config/gitlab.yml`:

   ```yaml
   auto_link_saml_user: true
   ```

1. Add the provider configuration.

   >**Notes:**
   >
   >- Change the value for `assertion_consumer_service_url` to match the HTTPS endpoint
   >  of GitLab (append `users/auth/saml/callback` to the HTTPS URL of your GitLab
   >  installation to generate the correct value).
   >
   >- To get the `idp_cert_fingerprint` fingerprint, first download the
   >  certificate from the Google Workspace app you registered and then run:
   >  `openssl x509 -in google_workspace.cert -noout -fingerprint` to generate the SHA1 fingerprint.
   >  Substitute `google_workspace.cert` with the location of your certificate.
   >
   >- Change the value of `idp_sso_target_url`, with the value of the
   >  **SSO URL** from the step when you configured the Google Workspace SAML app.
   >
   >- Change the value of `issuer` to the value of the **Entity ID** from your Google Workspace SAML app configuration. This will identify GitLab
   >  to the IdP.
   >
   >- Leave `name_identifier_format` as-is.

   **For Omnibus GitLab installations**

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: 'saml',
       args: {
                assertion_consumer_service_url: 'https://<GITLAB_DOMAIN>/users/auth/saml/callback',
                idp_cert_fingerprint: '00:00:00:00:00:00:0:00:00:00:00:00:00:00:00:00',
                idp_sso_target_url: 'https://accounts.google.com/o/saml2/idp?idpid=00000000',
                issuer: 'https://<GITLAB_DOMAIN>',
                name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress'
              },
       label: 'Google Workspace' # optional label for SAML log in button, defaults to "Saml"
     }
   ]
   ```

   **For installations from source**

   ```yaml
   - {
       name: 'saml',
       args: {
              assertion_consumer_service_url: 'https://<GITLAB_DOMAIN>/users/auth/saml/callback',
              idp_cert_fingerprint: '00:00:00:00:00:00:0:00:00:00:00:00:00:00:00:00',
              idp_sso_target_url: 'https://accounts.google.com/o/saml2/idp?idpid=00000000',
              issuer: 'https://<GITLAB_DOMAIN>',
              name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress'
            },
       label: 'Google Workspace' # optional label for SAML log in button, defaults to "Saml"
     }
   ```

1. [Reconfigure](../administration/restart_gitlab.md#omnibus-gitlab-reconfigure) or [restart](../administration/restart_gitlab.md#installations-from-source) GitLab for Omnibus and installations
   from source respectively for the changes to take effect.

To avoid caching issues, test the result on an incognito or private browser window.

## Troubleshooting

The Google Workspace documentation on [SAML app error messages](https://support.google.com/a/answer/6301076?hl=en) is helpful for debugging if you are seeing an error from Google while signing in.
Pay particular attention to the following 403 errors:

- `app_not_configured`
- `app_not_configured_for_user`
