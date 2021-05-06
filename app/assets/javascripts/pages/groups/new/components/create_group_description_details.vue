<script>
import { GlSprintf, GlLink } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
  computed: {
    groupsHelpPath() {
      return helpPagePath('user/group/index');
    },

    subgroupsHelpPath() {
      return helpPagePath('user/group/subgroups/index');
    },
  },
};
</script>

<template>
  <div>
    <p>
      <gl-sprintf
        :message="
          s__(
            'GroupsNew|%{linkStart}Groups%{linkEnd} allow you to manage and collaborate across multiple projects. Members of a group have access to all of its projects. Groups can also be nested by creating subgroups.',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="groupsHelpPath" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
    <p>
      <gl-sprintf
        :message="
          s__('GroupsNew|Groups can also be nested by creating %{linkStart}subgroups%{linkEnd}.')
        "
      >
        <template #link="{ content }">
          <gl-link :href="subgroupsHelpPath" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
  </div>
</template>
