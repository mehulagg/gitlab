import { s__ } from '~/locale';

export const SCAN_TYPE = {
  ACTIVE: 'ACTIVE',
  PASSIVE: 'PASSIVE',
};

export const SCAN_TYPE_OPTIONS = [
  {
    value: SCAN_TYPE.ACTIVE,
    text: s__('DastProfiles|Active'),
  },
  {
    value: SCAN_TYPE.PASSIVE,
    text: s__('DastProfiles|Passive'),
  },
];
