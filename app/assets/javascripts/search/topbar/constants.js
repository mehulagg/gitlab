import { __ } from '~/locale';

export const ANY = Object.freeze({
  id: null,
  name: __('Any'),
  name_with_namespace: __('Any'),
});

export const GROUP_DATA = {
  headerText: __('Filter results by group'),
  queryParam: 'group_id',
  selectedDisplayValue: 'name',
  resultsDisplayValue: 'full_name',
};

export const PROJECT_DATA = {
  headerText: __('Filter results by project'),
  queryParam: 'project_id',
  selectedDisplayValue: 'name_with_namespace',
  resultsDisplayValue: 'name_with_namespace',
};
