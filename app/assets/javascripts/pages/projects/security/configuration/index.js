import {
  initStaticSecurityConfiguration,
  initNewSecurityConfiguration,
} from '~/security_configuration';

const el = document.querySelector('#js-security-configuration-static');
if (gon.features.securityConfigurationRedesign) {
  initNewSecurityConfiguration(el);
} else {
  initStaticSecurityConfiguration(el);
}
