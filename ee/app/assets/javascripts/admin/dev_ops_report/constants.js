import { s__ } from '~/locale';

export const DEVOPS_ADOPTION_SEGMENT_MODAL_ID = 'devopsSegmentModal';

export const DEVOPS_ADOPTION_STRINGS = {
  emptyState: {
    title: s__('DevopsAdoption|Add a segment to get started'),
    description: s__(
      'DevopsAdoption|DevOps adoption uses segments to track adoption across key features. Segments are a way to track multiple related projects and groups at once. For example, you could create a segment for the engineering department or a particular product team.',
    ),
    button: s__('DevopsAdoption|Add new segment'),
  },
  modal: {
    title: s__('DevopsAdoption|New segment'),
    button: s__('DevopsAdoption|Create new segment'),
    namePlaceholder: s__('DevopsAdoption|My segment'),
    nameLabel: s__('DevopsAdoption|Name'),
    selectedGroupsTextSingular: s__('DevopsAdoption|%{selectedCount} group selected (20 max)'),
    selectedGroupsTextPlural: s__('DevopsAdoption|%{selectedCount} groups selected (20 max)'),
  },
};
