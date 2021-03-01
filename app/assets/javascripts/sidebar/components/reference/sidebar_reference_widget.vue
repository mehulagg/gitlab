<script>
import { GlIcon, GlLoadingIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import { referenceQueries } from '~/sidebar/constants';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  tracking: {
    event: 'click_button',
    label: 'right_sidebar',
    property: 'reference',
  },
  components: {
    GlIcon,
    GlLoadingIcon,
    ClipboardButton,
  },
  inject: ['fullPath', 'iid'],
  props: {
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      title: __('Copy reference'),
      text: __('Reference'),
    };
  },
  apollo: {
    reference: {
      query() {
        return referenceQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return data.workspace?.issuable?.reference || '';
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.reference.loading;
    },
  },
};
</script>

<template>
  <sidebar-editable-item
    ref="editable"
    title="text"
    :tracking="$options.tracking"
    :loading="isLoading"
    class="block confidentiality"
  >
    <template #collapsed>
      <div v-gl-tooltip.viewport.left :title="title" class="sidebar-collapsed-icon">
        <gl-icon :size="16" name="copy-to-clipboard" class="sidebar-item-icon inline" />
      </div>
    </template>
    <template #default>
      <div class="cross-project-reference hide-collapsed">
        <span>
          {{ text }}: {{ reference }}
          <gl-loading-icon v-if="isLoading" inline :label="text" />
        </span>
        <clipboard-button
          :title="title"
          :text="reference"
          css-class="btn-clipboard btn-link gl-line-height-24! gl-display-block"
          tooltip-placement="left"
        />
      </div>
    </template>
  </sidebar-editable-item>
</template>
