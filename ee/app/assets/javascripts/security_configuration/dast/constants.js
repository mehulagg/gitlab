export const DAST_SCANNER_PROFILE_PLACEHOLDER = '#DAST_SCANNER_PROFILE_NAME';
export const DAST_SITE_PROFILE_PLACEHOLDER = '#DAST_SITE_PROFILE_NAME';

export const DAST_YAML_CONFIGURATION_TEMPLATE = `# Add \`dast\` to your \`stages:\` configuration
stages:
  - dast

# Include the DAST template
include:
  - template: DAST.gitlab-ci.yml

# Your selected site and scanner profiles:
dast:
  stage: dast
  dast_configuration:
    site_profile: "${DAST_SITE_PROFILE_PLACEHOLDER}"
    scanner_profile: "${DAST_SCANNER_PROFILE_PLACEHOLDER}"
`;
