<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';

export default {
  name: 'DeleteBranchActionButton',
  components: { GlButton },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    branch: {
      type: String,
      required: false,
      default: '',
    },
    message: {
      type: String,
      required: false,
      default: 'Deleting the branch Branch Name cannot be undone. Are you sure?',
    },
    title: {
      type: String,
      required: false,
      default: 'Title',
    },
    icon: {
      type: String,
      required: false,
      default: 'remove',
    },
    tooltip: {
      type: String,
      required: false,
      default: '',
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    isProtectedBranch: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover
    class="js-delete-branch-button"
    variant="danger"
    :title="title"
    :aria-label="title"
    :icon="icon"
    :data-branch-path="branch"
    :data-is-protected-branch="isProtectedBranch"
    :data-message="message"
    data-qa-selector="delete_branch_button"
  />
</template>
