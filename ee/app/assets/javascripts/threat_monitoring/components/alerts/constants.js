import { s__ } from '~/locale';

export const MESSAGES = {
  CONFIGURE: s__(
    'ThreatMonitoring|No alerts available to display. See %{linkStart}enabling threat alerts%{linkEnd} for more information on adding alerts to the list.',
  ),
  ERROR: s__(
    "ThreatMonitoring|There was an error displaying the alerts. Confirm your endpoint's configuration details to ensure alerts appear.",
  ),
  NO_ALERTS: s__('ThreatMonitoring|No alerts to display.'),
  UPDATE_STATUS_ERROR: s__(
    'ThreatMonitoring|There was an error while updating the status of the alert. Please try again.',
  ),
};

export const STATUSES = {
  TRIGGERED: s__('ThreatMonitoring|Unreviewed'),
  ACKNOWLEDGED: s__('ThreatMonitoring|In review'),
  RESOLVED: s__('ThreatMonitoring|Resolved'),
  IGNORED: s__('ThreatMonitoring|Dismissed'),
};

export const CSS = {
  tbodyTrClass: 'gl-border-1 gl-border-t-solid gl-border-gray-100 gl-hover-cursor-pointer gl-hover-bg-blue-50 gl-hover-border-b-solid gl-hover-border-blue-200',
};

export const FIELDS = [
  {
    key: 'startedAt',
    label: s__('ThreatMonitoring|Date and time'),
    thAttr: { 'data-testid': 'threat-alerts-started-at-header' },
    thClass: `gl-bg-white! gl-w-15p`,
    tdClass: `gl-pl-6!`,
    sortable: true,
  },
  {
    key: 'alertLabel',
    label: s__('ThreatMonitoring|Name'),
    thClass: `gl-bg-white! gl-pointer-events-none`,
  },
  {
    key: 'status',
    label: s__('ThreatMonitoring|Status'),
    thAttr: { 'data-testid': 'threat-alerts-status-header' },
    thClass: `gl-bg-white! gl-w-15p`,
    tdClass: `gl-pl-6!`,
    sortable: true,
  },
];

export const PAGE_SIZE = 20;

export const DEFAULT_FILTERS = { statuses: ['TRIGGERED', 'ACKNOWLEDGED'] };
