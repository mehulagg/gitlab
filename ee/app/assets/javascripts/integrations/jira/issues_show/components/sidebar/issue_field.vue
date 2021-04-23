<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import IssueFieldDropdown from './issue_field_dropdown.vue';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlIcon,
    IssueFieldDropdown,
    SidebarEditableItem,
  },
  provide: {
    isClassicSidebar: true,
    canUpdate: true,
  },
  props: {
    dropdownTitle: {
      type: String,
      required: false,
      default: null,
    },
    icon: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    tooltipProps() {
      return {
        boundary: 'viewport',
        placement: 'left',
        title: this.value || this.title,
      };
    },
    valueWithFallback() {
      return this.value || this.$options.i18n.none;
    },
    valueClass() {
      return {
        'no-value': !this.value,
      };
    },
  },
  i18n: {
    none: __('None'),
  },
  methods: {
    showDropdown() {
      this.$refs.dropdown.showDropdown();
    },
    expandSidebarAndOpenDropdown() {
      this.$emit('expand-sidebar', this.$refs.editableItem);
    },
  },
};
</script>

<template>
  <div class="block">
    <sidebar-editable-item ref="editableItem" :title="title" @open="showDropdown">
      <template #collapsed>
        <div
          v-gl-tooltip="tooltipProps"
          class="sidebar-collapsed-icon"
          data-testid="field-collapsed"
          @click="expandSidebarAndOpenDropdown"
        >
          <gl-icon :name="icon" />
        </div>

        <div class="hide-collapsed">
          <div class="value">
            <span :class="valueClass" data-testid="field-value">{{ valueWithFallback }}</span>
          </div>
        </div>
      </template>

      <template #default>
        <issue-field-dropdown ref="dropdown" :text="valueWithFallback" :title="dropdownTitle" />
      </template>
    </sidebar-editable-item>
  </div>
</template>
