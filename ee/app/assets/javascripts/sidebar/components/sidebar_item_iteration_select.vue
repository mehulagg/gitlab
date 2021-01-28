<script>
import { GlButton, GlIcon, GlLink, GlTooltipDirective } from '@gitlab/ui';
import IterationSelect from './iteration_select.vue';
import { iterationSelectTextMap } from '../constants';
import { __ } from '~/locale';

export default {
  i18n: {
    iterationText: iterationSelectTextMap.iteration,
    edit: __('Edit'),
    none: __('None'),
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlIcon,
    GlLink,
    IterationSelect,
  },
  props: {
    canEdit: {
      required: true,
      type: Boolean,
    },
    groupPath: {
      required: true,
      type: String,
    },
    projectPath: {
      required: true,
      type: String,
    },
    issueIid: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      editing: false,
      currentIteration: null,
    };
  },
  computed: {
    iterationTitle() {
      return this.currentIteration?.title;
    },
    iterationUrl() {
      return this.currentIteration?.webUrl;
    },
    showNoIterationContent() {
      return !this.editing && this.currentIteration === null;
    },
  },
  mounted() {
    document.addEventListener('click', this.handleOffClick);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.handleOffClick);
  },
  methods: {
    onIterationUpdate(currentIteration) {
      this.currentIteration = currentIteration;
    },
    toggleEdit() {
      this.editing = !this.editing;
    },
    handleOffClick(event) {
      if (!this.editing) return;

      if (!this.$refs.iterationDropdown.$el.contains(event.target)) {
        this.toggleEdit();
      }
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <div v-gl-tooltip class="sidebar-collapsed-icon" data-testid="iteration-title">
      <gl-icon :size="16" :aria-label="$options.i18n.iterationText" name="iteration" />
      <span class="collapse-truncated-title">{{ iterationTitle }}</span>
    </div>
    <div class="title hide-collapsed gl-mt-4">
      {{ $options.i18n.iterationText }}
      <gl-button
        v-if="canEdit"
        variant="link"
        class="js-sidebar-dropdown-toggle edit-link gl-shadow-none float-right gl-reset-color! btn-link-hover"
        data-testid="iteration-edit-link"
        data-track-label="right_sidebar"
        data-track-property="iteration"
        data-track-event="click_edit_button"
        data-qa-selector="edit_iteration_link"
        @click.stop="toggleEdit"
        >{{ $options.i18n.edit }}</gl-button
      >
    </div>
    <div data-testid="select-iteration" class="hide-collapsed">
      <span v-if="showNoIterationContent" class="no-value">{{ $options.i18n.none }}</span>
      <gl-link v-else-if="!editing" data-qa-selector="iteration_link" :href="iterationUrl"
        ><strong>{{ iterationTitle }}</strong></gl-link
      >
    </div>
    <iteration-select
      ref="iterationDropdown"
      :group-path="groupPath"
      :project-path="projectPath"
      :issue-iid="issueIid"
      :dropdown-open="editing"
      @dropdownClose="toggleEdit"
      @iterationUpdate="onIterationUpdate"
    />
  </div>
</template>
