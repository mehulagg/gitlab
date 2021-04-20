import SamlSettingsForm from 'ee/saml_providers/saml_settings_form';
import SCIMTokenToggleArea from 'ee/saml_providers/scim_token_toggle_area';

export default function initSAML() {
  const groupPath = document.querySelector('#issuer').value;

  // eslint-disable-next-line no-new
  new SCIMTokenToggleArea(
    '.js-generate-scim-token-container',
    '.js-scim-token-container',
    groupPath,
  );
  new SamlSettingsForm('.js-saml-settings-form').init();
}
