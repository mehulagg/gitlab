# SAML SSO for Groups **[PREMIUM]**

> Introduced in [GitLab Premium](https://about.gitlab.com/pricing/) 11.0.

This allows SAML to be used for adding users to a group on GitLab.com and other instances where using [site-wide SAML](../../../integration/saml.md) is not possible.

When using a group SAML SSO link, users should already have an account on the GitLab instance with the email address that matches the user account from the provider.

NOTE: **Note:** SAML SSO for groups is used only as a convenient way to add users and does not sync users between providers. Group owners will still need to manage user accounts, such as removing users when necessary.

## How to configure

1. Navigate to the group and click Settings -> SAML SSO.
1. Configure your SAML server using the **Assertion consumer service URL** and **Issuer**. See [your identity provider's documentation](#providers) for more details.
1. Configure required assertions using the table below.
1. Find the SSO URL from your Identity Provider and enter it on GitLab.
1. Find and enter the fingerprint for the SAML token signing certificate.

## NameID

GitLab.com uses the SAML NameID to identify users, so it must be present in the SAML response and unique to the user.

The value should be something that will never change for that user, such as a unique ID or username. Email could also be used as the NameID, but only if it can be guaranteed to never change.

## Assertions

| Field | Supported keys | Notes |
|-|----------------|-------------|
| Email | `email`, `mail` | (required) |
| Full Name | `name` |  |
| First Name | `first_name`, `firstname`, `firstName` |  |
| Last Name | `last_name`, `lastname`, `lastName` |  |

## Providers

| Provider | Documentation |
|----------|---------------|
| ADFS (Active Directory Federation Services) | [Create a Relying Party Trust](https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/operations/create-a-relying-party-trust) |
| Azure | [Configuring single sign-on to applications](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-saas-custom-apps) |
| Auth0 | [Auth0 as Identity Provider](https://auth0.com/docs/protocols/saml/saml-idp-generic) |
| G Suite | [Set up your own custom SAML application](https://support.google.com/a/answer/6087519?hl=en) |
| JumpCloud | [Single Sign On (SSO) with GitLab](https://support.jumpcloud.com/customer/en/portal/articles/2810701-single-sign-on-sso-with-gitlab) |
| Okta | [Setting up a SAML application in Okta](https://developer.okta.com/standards/SAML/setting_up_a_saml_application_in_okta) |
| OneLogin | [Use the OneLogin SAML Test Connector](https://onelogin.service-now.com/support?id=kb_article&sys_id=93f95543db109700d5505eea4b96198f) |
| Ping Identity | [Add and configure a new SAML application](https://docs.pingidentity.com/bundle/p1_enterpriseConfigSsoSaml_cas/page/enableAppWithoutURL.html) |

## Glossary

| Term | Description |
|------|-------------|
| Identity Provider | The service which manages your user identities such as ADFS, Okta, Onelogin or Ping Identity. |
| Service Provider | SAML considers GitLab to be a service provider. |
| Assertion | A piece of information about a user's identity, such as their name or role. Also know as claims or attributes. |
| SSO | Single Sign On. |
| Assertion consumer service URL | The callback on GitLab where users will be redirected after successfully authenticating with the identity provider. |
| Issuer | How GitLab identifies itself to the identity provider. Also known as a "Relying party trust identifier". |
| Certificate fingerprint | Used to confirm that communications over SAML are secure by checking that the server is signing communications with the correct certificate. Also known as a certificate thumbprint. |
