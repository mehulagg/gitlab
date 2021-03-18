---
comments: false
type: index
stage: Manage
group: Access
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab authentication and authorization

GitLab integrates with the following external authentication and authorization
providers:

- [Atlassian](atlassian.md)
- [Auth0](../../integration/auth0.md)
- [Authentiq](authentiq.md)
- [AWS Cognito](cognito.md)
- [Azure](../../integration/azure.md)
- [Bitbucket Cloud](../../integration/bitbucket.md)
- [CAS](../../integration/cas.md)
- [Crowd](crowd.md)
- [Facebook](../../integration/facebook.md)
- [GitHub](../../integration/github.md)
- [GitLab.com](../../integration/gitlab.md)
- [Google OAuth](../../integration/google.md)
- [Google Workspace SSO](../../integration/google_workspace_saml.md)
- [JWT](jwt.md)
- [Kerberos](../../integration/kerberos.md)
- [LDAP](ldap/index.md): Includes Active Directory, Apple Open Directory, Open LDAP,
  and 389 Server.
  - [Google Secure LDAP](ldap/google_secure_ldap.md)
- [Okta](okta.md)
- [Salesforce](../../integration/salesforce.md)
- [SAML](../../integration/saml.md)
- [SAML for GitLab.com groups](../../user/group/saml_sso/index.md) **(PREMIUM SAAS)**
- [Shibboleth](../../integration/shibboleth.md)
- [Smartcard](smartcard.md) **(PREMIUM SELF)**
- [Twitter](../../integration/twitter.md)

NOTE:
UltraAuth has removed their software which supports OmniAuth integration. We have therefore removed all references to UltraAuth integration.

# SaaS vs Self-Managed Comparison

| Capability                                      | SaaS                                    | Self-Managed                                                            |
|-------------------------------------------------|-----------------------------------------|-------------------------------------------------------------------------|
| **User Provisioning**                           | SCIM<br> SAML JIT Provisioning                | LDAP Sync                                                               |
| **User Detail Updating** (not group management) | SCIM (but only Azure)                   | LDAP Sync                                                               |
| **Authentication**                              | SAML at top-level group (1 provider)    | SAML via OmniAuth (1 provider)<br>LDAP (multiple providers)<br>Kerberos |
| **Provider-to-GitLab Role Sync**                | SAML Group Sync                         | LDAP Group Sync                                                         |
| **User Removal**                                | SAML and SCIM (remove user from top-level group) | LDAP (Blocking User from Instance)                                      |
