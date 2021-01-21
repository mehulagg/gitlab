import initFirstClassSecurityDashboard from 'ee/security_dashboard/first_class_init';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';

initFirstClassSecurityDashboard(
  document.getElementById('js-vulnerabilities'),
  DASHBOARD_TYPES.INSTANCE,
);
