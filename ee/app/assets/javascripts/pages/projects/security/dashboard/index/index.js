import initSecurityCharts from 'ee/security_dashboard/security_charts_init';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { waitForCSSLoaded } from '~/helpers/startup_css_helper';

waitForCSSLoaded(() => {
  initSecurityCharts(
    document.getElementById('js-project-security-dashboard'),
    DASHBOARD_TYPES.PROJECT,
  );
});
