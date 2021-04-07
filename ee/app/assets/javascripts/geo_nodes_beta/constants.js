import { helpPagePath } from '~/helpers/help_page_helper';

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

export const STATUS_DELAY_THRESHOLD_MS = 600000;
