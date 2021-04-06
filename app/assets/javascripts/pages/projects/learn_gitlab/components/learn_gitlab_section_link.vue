<script>
import { GlLink, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { ACTION_LABELS } from '../constants';

export default {
  name: 'LearnGitlabSectionLink',
  components: { GlLink, GlIcon },
  i18n: {
    ACTION_LABELS,
  },
  props: {
    action: {
      required: true,
      type: String,
    },
    value: {
      required: true,
      type: Object,
    },
  },
};
</script>
<template>
  <div class="gl-mb-4">
    <span v-if="value.completed" class="gl-text-green-500">
      <gl-icon
        v-if="value.completed"
        name="check-circle-filled"
        class="gl-text-green-500"
        :size="16"
        data-testid="completed-icon"
      />
      {{ $options.i18n.ACTION_LABELS[action].title }}
    </span>
    <span v-else>
      <gl-link :href="value.url">{{ $options.i18n.ACTION_LABELS[action].title }}</gl-link>
    </span>
  </div>
</template>
