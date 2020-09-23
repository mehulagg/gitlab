import { gray700, orange400 } from '@gitlab/ui/scss_to_js/scss_variables';
import { s__ } from '~/locale';

export const TOTAL_REQUESTS = s__('ThreatMonitoring|Total Requests');
export const ANOMALOUS_REQUESTS = s__('ThreatMonitoring|Anomalous Requests');
export const TIME = s__('ThreatMonitoring|Time');
export const REQUESTS = s__('ThreatMonitoring|Requests');

export const COLORS = {
  nominal: gray700,
  anomalous: orange400,
};

// Reuse existing definitions rather than defining them again here,
// otherwise they could get out of sync.
// See https://gitlab.com/gitlab-org/gitlab-ui/issues/554.
export { dateFormats as DATE_FORMATS } from 'ee/analytics/shared/constants';
