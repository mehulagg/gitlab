---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# FIPS compliance

FIPS is short for "Federal Information Processing Standard", a document which
defines certain security practices for a "cryptographic module" (CMs). It aims
to ensure a certain security floor is met by vendors selling products to U.S.
Federal institutions.

There are two current FIPS standards: [140-2](https://en.wikipedia.org/wiki/FIPS_140-2)
and [140-3](https://en.wikipedia.org/wiki/FIPS_140-3) . At GitLab we usually
mean FIPS 140-2.

(is this true, are we plannign to go to 140-3 soon, are there non-140 documents
of equal relevance?)

## FIPS compliance at GitLab

Is GitLab a CM for the purposes of FIPS 140-2, or does it just have to be capable
of functioning in an environment where all CMs are FIPS-compliant?

Do we want to specify that all new code must be FIPS-compliant?

Does JS running in the client's browser need to be FIPS-compliant for GitLab to
be FIPS-compliant? My first feeling is yes.

## Current status

WARNING:
GitLab is not FIPS compliant, even when built and run on a FIPS-enforcing
system. Large parts of the build are broken, and many features use forbidden
cryptographic primitives. Running GitLab against FIPS-enforcing CMs is not
supported and may result in data loss.

We don't yet know whether we want to make GitLab FIPS-compliant or not. In the
13.10 release cycle we are performing some initial investigation to try to see
how much work such an effort would be.

[Epic &5104](https://gitlab.com/groups/gitlab-org/-/epics/5104) is the rallying
point for GitLab FIPS compliance.

## Setting up a FIPS-enabled development environment

The simplest approach is to set up a virtual machine running
[Red Hat Enterprise Linux 8](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening#switching-the-system-to-fips-mode_using-the-system-wide-cryptographic-policies)
and install [GDK](https://gitlab.com/gitlab-org/gitlab-development-kit)
in it.

Red Hat provide free licenses to developers, and permit the CD image to be
downloaded from the [Red Hat developer's portal](https://developers.redhat.com),
although registration is required.

Once installed, you'll have to run this command and restart to enable FIPS mode:

```shell
# fips-mode-setup --enable
```

Then, you can follow GDK's installation instructions for RHEL:

- Prerequisites
- Advanced install ([in flight](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/1852))

## Fixing FIPS-related issues

...

GitLab uses three main languages: Ruby, Go, and JavaScript (either in the user's
browser or on the server via Node).

...
