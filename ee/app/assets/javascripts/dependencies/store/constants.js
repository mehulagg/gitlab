import { s__ } from '~/locale';
import { FILTER } from './modules/list/constants';

export const DEPENDENCY_LIST_TYPES = {
  all: {
    namespace: 'allDependencies',
    label: s__('Dependencies|All'),
    initialState: {
      filter: FILTER.all,
    },
  },
  // This is only used in tests, and will be removed in
  // https://gitlab.com/gitlab-org/gitlab/-/issues/217734
  vulnerable: {
    namespace: 'vulnerableDependencies',
    label: s__('Dependencies|Vulnerable components'),
    initialState: {
      filter: FILTER.vulnerable,
    },
  },
};
