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

export const HELP_NODE_HEALTH_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html#check-the-health-of-the-secondary-node';

export const GEO_TROUBLESHOOTING_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html';
