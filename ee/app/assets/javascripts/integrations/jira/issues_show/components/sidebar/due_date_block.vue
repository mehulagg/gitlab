<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: { GlIcon },
  props: {
    dueDate: {
      type: Date,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div>
    <div class="sidebar-collapsed-icon">
      <gl-icon name="calendar" />
      <span v-if="dueDate"> {{ dueDate }} </span>
      <span v-else> {{ __('None') }} </span>
    </div>

    <div class="title hide-collapsed">
      {{ __('Due date') }}
    </div>
    <div class="value hide-collapsed">
      <span class="value-content">
        <span v-if="dueDate" class="gl-font-weight-bold"> {{ dueDate }} </span>
        <span v-else class="no-value"> {{ __('None') }} </span>
      </span>
    </div>
  </div>
</template>
