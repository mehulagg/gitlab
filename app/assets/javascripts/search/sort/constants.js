import { __ } from '~/locale';

export const MOST_RELEVANT = {
  id: 1,
  title: __('Most Relevant'),
  sortable: false,
  sortParam: 'relevant',
};

export const CREATED_DATE = {
  id: 2,
  title: __('Created Date'),
  sortable: true,
  sortParam: {
    asc: 'created_asc',
    desc: 'created_desc',
  },
};

export const SORT_OPTIONS = [MOST_RELEVANT, CREATED_DATE];

export const SORT_DIRECTION_UI = {
  disabled: {
    direction: null,
    tooltip: '',
    icon: 'sort-highest',
  },
  desc: {
    direction: 'desc',
    tooltip: __('Sort direction: Descending'),
    icon: 'sort-highest',
  },
  asc: {
    direction: 'asc',
    tooltip: __('Sort direction: Ascending'),
    icon: 'sort-lowest',
  },
};
