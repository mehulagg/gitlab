export const DAST_YAML_CONFIGURATION_TEMPLATE = `# Add \`dast\` to your \`stages:\` configuration
stages:
  - dast

variables:
  - DAST_SITE_PROFILE: #DAST_SITE_PROFILE_NAME
  - DAST_SCANNER_PROFILE: #DAST_SCANNER_PROFILE_NAME
`;

export const DAST_SCANNER_PROFILE_PLACEHOLDER = '#DAST_SCANNER_PROFILE_NAME';
export const DAST_SITE_PROFILE_PLACEHOLDER = '#DAST_SITE_PROFILE_NAME';
