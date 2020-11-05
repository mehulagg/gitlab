import initFirstClassSecurityDashboard from 'ee/security_dashboard/first_class_init';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';

document.addEventListener('DOMContentLoaded', () => {
  initFirstClassSecurityDashboard(
    document.getElementById('js-vulnerabilities'),
    DASHBOARD_TYPES.INSTANCE,
  );
});
