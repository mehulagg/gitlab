export const DAST_YML_CONFIGURATION_TEMPLATE = `# Add \`dast\` to your \`stages:\` configuration
stages:
  - dast

variables:
  - DAST_SITE_PROFILE: #DAST_SITE_PROFILE_NAME
  - DAST_SCANNER_PROFILE: #DAST_SCANNER_PROFILE_NAME
`;
