<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import SidebarConfidentialityForm from '~/sidebar/components/confidential/sidebar_confidentiality_form.vue';
import { __, sprintf } from '~/locale';
import Sidebar_confidentiality_form from './sidebar_confidentiality_form.vue';

export default {
  tracking: {
    event: 'click_edit_button',
    label: 'right_sidebar',
    property: 'confidentiality',
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    SidebarEditableItem,
    GlIcon,
    SidebarConfidentialityForm,
  },
  props: {
    issuableType: {
      required: false,
      type: String,
      default: 'issue',
    },
  },
  data() {
    return {
      confidential: false,
    };
  },
  computed: {
    confidentialText() {
      return sprintf(__('This %{issuableType} is confidential'), {
        issuableType: this.issuableType,
      });
    },
  },
};
</script>

<template>
  <sidebar-editable-item :title="__('Confidentiality')" :tracking="$options.tracking" class="block">
    <template #collapsed>
      <div v-if="!confidential" data-testid="not-confidential">
        <gl-icon :size="16" name="eye" class="sidebar-item-icon inline" />
        {{ __('Not confidential') }}
      </div>
      <div v-else>
        <gl-icon :size="16" name="eye-slash" class="sidebar-item-icon inline is-active" />
        {{ confidentialText }}
      </div>
    </template>
    <template #default>
      <div v-if="!confidential" data-testid="not-confidential">
        <gl-icon :size="16" name="eye" class="sidebar-item-icon inline" />
        {{ __('Not confidential') }}
      </div>
      <div v-else>
        <gl-icon :size="16" name="eye-slash" class="sidebar-item-icon inline is-active" />
        {{ confidentialText }}
      </div>
      <sidebar-confidentiality-form :confidential="confidential" :issuable-type="issuableType" />
    </template>
  </sidebar-editable-item>
</template>
