import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import vulnerabilityReportInit from 'ee/security_dashboard/vulnerability_report_init';

vulnerabilityReportInit(document.getElementById('js-vulnerabilities'), DASHBOARD_TYPES.INSTANCE);
