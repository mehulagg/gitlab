import { initSecurityConfiguration } from 'ee/security_configuration';
import {
  initStaticSecurityConfiguration,
  initNewSecurityConfiguration,
} from '~/security_configuration';

const el = document.querySelector('#js-security-configuration');
const useNewDesign = gon.features.securityConfigurationRedesign;

if (useNewDesign) {
  initNewSecurityConfiguration(el || document.querySelector('#js-security-configuration-static'));
} else if (el) {
  initSecurityConfiguration(el);
} else {
  initStaticSecurityConfiguration(document.querySelector('#js-security-configuration-static'));
}
