<script>
  import { GlEmptyState, GlButton } from '@gitlab/ui';
  import { s__ } from '~/locale';

  const i18n = {
    emptyState: {
      title: s__('OnCallSchedules|Create on-call schedules  in GitLab'),
      description: s__('OnCallSchedules|Route alerts directly to specific members of your team'),
      button: s__('OnCallSchedules|Add a schedule'),
    },

  };

  export default {
    i18n,
    inject: ['emptyOnCallScheduleSvgPath'],
    components: {
      GlEmptyState,
      GlButton,
    },
    methods: {
      createSchedule(){}
    }
  };
</script>

<template>
  <gl-empty-state
    :title="$options.i18n.emptyState.title"
    :description="$options.i18n.emptyState.description"
    :svg-path="emptyOnCallScheduleSvgPath">
    <template #actions>
      <gl-button variant="info" @click="createSchedule">{{ $options.i18n.emptyState.button }}</gl-button>
    </template>
  </gl-empty-state>
</template>
