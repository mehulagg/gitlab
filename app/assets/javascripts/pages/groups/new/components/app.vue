<script>
import createFromTemplateIllustration from '@gitlab/svgs/dist/illustrations/project-create-from-template-sm.svg';
import blankProjectIllustration from '@gitlab/svgs/dist/illustrations/project-create-new-sm.svg';

import { s__ } from '~/locale';
import NewNamespacePage from '~/vue_shared/new_namespace/new_namespace_page.vue';
import createGroupDescriptionDetails from './create_group_description_details.vue';

const PANELS = [
  {
    name: 'create-group-pane',
    selector: '#create-group-pane',
    title: s__('GroupsNew|Create group'),
    description: s__(
      'GroupsNew|Assemble related projects together and grant members access to several projects at once.',
    ),
    illustration: blankProjectIllustration,
    details: createGroupDescriptionDetails,
  },
  {
    name: 'import-group-pane',
    selector: '#import-group-pane',
    title: s__('GroupsNew|Import group'),
    description: s__(
      'GroupsNew|Export groups with all their related data and move to a new GitLab instance.',
    ),
    illustration: createFromTemplateIllustration,
    details: 'Migrate your existing groups from another instance of GitLab.',
  },
];

export default {
  components: {
    NewNamespacePage,
  },
  PANELS,
};
</script>

<template>
  <new-namespace-page
    :initial-breadcrumb="s__('New group')"
    :panels="$options.PANELS"
    :title="s__('GroupsNew|Create new group')"
    persistence-key="new_group_last_active_tab"
  />
</template>
