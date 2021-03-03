import { initSecurityConfiguration } from 'ee/security_configuration';
import { initStaticSecurityConfiguration } from '~/security_configuration';

const el = document.querySelector('#js-security-configuration');

if (el) {
  initSecurityConfiguration(el);
} else {
  initStaticSecurityConfiguration(document.querySelector('#js-security-configuration-static'));
}
