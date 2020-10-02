import { __ } from '~/locale';
export const MAX_MILESTONES_TO_DISPLAY = 5;

export const BACK_URL_PARAM = 'back_url';

export const ASSET_LINK_TYPE = Object.freeze({
  OTHER: 'other',
  IMAGE: 'image',
  PACKAGE: 'package',
  RUNBOOK: 'runbook',
});

export const DEFAULT_ASSET_LINK_TYPE = ASSET_LINK_TYPE.OTHER;

export const PAGE_SIZE = 20;

export const ASCENDING_ODER = 'asc';
export const DESCENDING_ORDER = 'desc';

export const SORT_OPTIONS = [
  {
    orderBy: 'released_at',
    label: __('Released at'),
  },
  {
    orderBy: 'created_at',
    label: __('Created at'),
  },
];
