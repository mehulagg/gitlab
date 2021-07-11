import { initSecurityConfiguration } from 'ee/security_configuration';
import { initCESecurityConfiguration } from '~/security_configuration';

const el = document.querySelector('#js-security-configuration');

if (el) {
  initSecurityConfiguration(el);
} else {
  initCESecurityConfiguration(document.querySelector('#js-security-configuration-static'));
}
