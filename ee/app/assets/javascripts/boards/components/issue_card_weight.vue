<script>
import { GlTooltip } from '@gitlab/ui';
import icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'IssueCardWeight',
  components: {
    icon,
    GlTooltip,
  },
  props: {
    weight: {
      type: Number,
      required: false,
    },
  },
};
</script>

<template>
  <div ref="itemWeight" class="board-card-info card-number board-card-weight" v-on="$listeners">
    <icon name="weight" class="board-card-info-icon" />
    <span class="board-card-info-text">{{ weight }}</span>
    <gl-tooltip
      :target="() => $refs.itemWeight"
      placement="bottom"
      container="body"
      class="js-item-weight"
    >
      {{ __('Weight') }}
      <br />
      <span class="text-tertiary">{{ weight }}</span>
    </gl-tooltip>
  </div>
</template>
