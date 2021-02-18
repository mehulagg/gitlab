---
stage: Secure, Protect
group: all
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: index, dev, reference
---

# Application Security development documentation

Development guides that are specific to the stages that work on Application Security features are listed here.

If you are looking for how to use those features, that documentation can be found [here](../../user/application_security/index.md).

## Namespaces

Application Security code in the Rails monolith is organized into the following namespaces, which generally following
the feature categories on the Secure [stage page](https://about.gitlab.com/stages-devops-lifecycle/secure/).

- Shared code lives in the `AppSec` namespace
- Vulnerability Management code lives in the `AppSec::Vulnerabilities` namespace
- SAST code lives in the `AppSec::Sast` namespace
- DAST code lives in the `AppSec::Dast` namespace
- Secret Detection code lives in the `AppSec::SecretDetection` namespace
- License Compliance code lives in the `AppSec::LicenseCompliance` namespace
- Dependency Scanning code lives in the `AppSec::DependencyScanning` namespace
- Shared fuzzing code lives in the `AppSec::Fuzzing` namespace
- Coverage Fuzzing code lives in the `AppSec::Fuzzing::Coverage` namespace
- API Fuzzing code lives in the `AppSec::Fuzzing::Api` namespace

At the time of writing, most AppSec code does not conform to these namespace guidelines. When developing, make an effort
to move existing code into the appropriate namespace whenever possible.
