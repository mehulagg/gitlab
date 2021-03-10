---
stage: Protect
group: Container Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Getting started with Security Orchestration

## Installation steps

The following steps are recommended to install and use Security Orchestration through GitLab:

1. [Enable DAST scanning on a project](../../../../application_security/dast/index.md#enable-dast).
1. Create a new project containing the security scan policies:

    - Create a new project
    - Create a policy file at `.gitlab/security-policies/<POLICY_NAME>.yml`
    - The policy file should be of the structure

      ```yaml
      type: scan_execution_policy
      name: Run DAST in every pipeline
      description: This policy enforces to run DAST for every pipeline within the project
      enabled: true
      rules:
      - type: pipeline
        branches:
        - "master"
      actions:
      - scan: dast
        site_profile: Site Profile
        scanner_profile: Scanner Profile
      ```

1. Link the policy project to the project of interest via `Security & Compliance` -> `Scan Policies`
1. [Create a DAST site profile of the same name in the project of interest](../../../../application_security/dast/index.md#create-a-site-profile).
1. [Create a DAST scanner profile of the same name in the project of interest](../../../../application_security/dast/index.md#create-a-scanner-profile).
