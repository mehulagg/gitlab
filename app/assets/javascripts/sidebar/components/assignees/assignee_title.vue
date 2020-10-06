<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { n__, __ } from '~/locale';

export default {
  name: 'AssigneeTitle',
  components: {
    GlLoadingIcon,
  },
  props: {
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    numberOfAssignees: {
      type: Number,
      required: true,
    },
    editable: {
      type: Boolean,
      required: true,
    },
    showToggle: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      editing: false,
    };
  },
  computed: {
    assigneeTitle() {
      const assignees = this.numberOfAssignees;
      return n__('Assignee', `%d Assignees`, assignees);
    },
    titleCopy() {
      return this.editing ? __('Apply') : __('Edit');
    },
  },
  mounted() {
    document.addEventListener('click', this.doSomething);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.doSomething);
  },
  methods: {
    doSomething() {
      this.editing = !this.editing;
    },
  },
};
</script>
<template>
  <div class="title hide-collapsed">
    {{ assigneeTitle }}
    <gl-loading-icon v-if="loading" inline class="align-bottom" />
    <a
      v-if="editable"
      class="js-sidebar-dropdown-toggle edit-link float-right"
      href="#"
      data-track-event="click_edit_button"
      data-track-label="right_sidebar"
      data-track-property="assignee"
    >
      {{ titleCopy }}
    </a>
    <a
      v-if="showToggle"
      :aria-label="__('Toggle sidebar')"
      class="gutter-toggle float-right js-sidebar-toggle"
      href="#"
      role="button"
    >
      <i aria-hidden="true" data-hidden="true" class="fa fa-angle-double-right"></i>
    </a>
  </div>
</template>
