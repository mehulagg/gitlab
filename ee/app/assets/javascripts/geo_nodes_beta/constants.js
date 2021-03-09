import { helpPagePath } from '~/helpers/help_page_helper';
import { __ } from '~/locale';

export const GEO_INFO_URL = helpPagePath('administration/geo/index.md');

export const GEO_FEATURE_URL = 'https://about.gitlab.com/features/gitlab-geo/';

export const HELP_NODE_HEALTH_URL = helpPagePath(
  'administration/geo/replication/troubleshooting.html#check-the-health-of-the-secondary-node',
);

export const GEO_TROUBLESHOOTING_URL = helpPagePath(
  'administration/geo/replication/troubleshooting.html',
);

export const HELP_INFO_URL = helpPagePath(
  'administration/geo/disaster_recovery/background_verification.html',
  { anchor: 'repository-verification' },
);

export const REPLICATION_PAUSE_URL = helpPagePath('administration/geo/index.html', {
  anchor: 'pausing-and-resuming-replication',
});

export const HEALTH_STATUS_UI = {
  healthy: {
    icon: 'status_success',
    variant: 'success',
  },
  unhealthy: {
    icon: 'status_failed',
    variant: 'danger',
  },
  disabled: {
    icon: 'status_canceled',
    variant: 'neutral',
  },
  unknown: {
    icon: 'status_notfound',
    variant: 'neutral',
  },
  offline: {
    icon: 'status_canceled',
    variant: 'neutral',
  },
};

export const REPLICATION_STATUS_UI = {
  enabled: {
    icon: 'play',
    color: 'gl-text-green-600',
    text: __('Enabled'),
  },
  disabled: {
    icon: 'pause',
    color: 'gl-text-orange-600',
    text: __('Paused'),
  },
};

export const STATUS_DELAY_THRESHOLD_MS = 600000;
