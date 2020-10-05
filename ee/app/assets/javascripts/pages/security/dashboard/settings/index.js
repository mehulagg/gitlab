import initInstanceSecurityDashboardSettings from 'ee/security_dashboard/instance_dashboard_settings_init';

document.addEventListener('DOMContentLoaded', () => {
  initInstanceSecurityDashboardSettings(document.getElementById('js-security'));
});
