export const NODE_ACTION_BASE_PATH = '/admin/geo_nodes/';

export const NODE_ACTIONS = {
  TOGGLE: '/toggle',
  EDIT: '/edit',
  REPAIR: '/reconfigure',
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
  unknown: 'status_warning',
  offline: 'status_canceled',
};

export const TIME_DIFF = {
  FIVE_MINS: 300,
  HOUR: 3600,
};
