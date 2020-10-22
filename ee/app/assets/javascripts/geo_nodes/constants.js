export const NODE_ACTIONS = {
  TOGGLE: 'toggle',
  REMOVE: 'remove',
};

export const VALUE_TYPE = {
  PLAIN: 'plain',
  GRAPH: 'graph',
  CUSTOM: 'custom',
};

export const CUSTOM_TYPE = {
  SYNC: 'sync',
  EVENT: 'event',
  STATUS: 'status',
};

export const HEALTH_STATUS_ICON = {
  healthy: 'status_success',
  unhealthy: 'status_failed',
  disabled: 'status_canceled',
  unknown: 'status_notfound',
  offline: 'status_canceled',
};

export const HEALTH_STATUS_CLASS = {
  healthy: 'text-success-600 bg-success-100',
  unhealthy: 'text-danger-600 bg-danger-100',
  disabled: 'text-secondary-800 bg-secondary-100',
  unknown: 'text-secondary-800 bg-secondary-100',
  offline: 'text-secondary-800 bg-secondary-100',
};

export const REPLICATION_STATUS_CLASS = {
  enabled: 'gl-text-green-600 gl-bg-green-100',
  disabled: 'gl-text-orange-600 gl-bg-orange-100',
};

export const REPLICATION_STATUS_ICON = {
  enabled: 'play',
  disabled: 'pause',
};

export const TIME_DIFF = {
  FIVE_MINS: 300,
  HOUR: 3600,
};

export const STATUS_DELAY_THRESHOLD_MS = 600000;

export const HELP_INFO_URL =
  'https://docs.gitlab.com/ee/administration/geo/disaster_recovery/background_verification.html#repository-verification';

export const REPLICATION_HELP_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/datatypes.html#limitations-on-replicationverification';

export const REPLICATION_PAUSE_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/#pausing-and-resuming-replication';

export const HELP_NODE_HEALTH_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html#check-the-health-of-the-secondary-node';

export const GEO_TROUBLESHOOTING_URL =
  'https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html';
