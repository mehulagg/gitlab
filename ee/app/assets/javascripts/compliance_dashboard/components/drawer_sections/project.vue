<script>
import { GlAvatarLabeled, GlAvatarLink } from '@gitlab/ui';
import ComplianceFrameworkLabel from 'ee/vue_shared/components/compliance_framework_label/compliance_framework_label.vue';
import { __ } from '~/locale';

export default {
  components: {
    ComplianceFrameworkLabel,
    GlAvatarLabeled,
    GlAvatarLink,
  },
  props: {
    avatarUrl: {
      type: String,
      required: false,
      default: '',
    },
    complianceFramework: {
      type: Object,
      required: false,
      default: null,
    },
    name: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: true,
    },
  },
  i18n: {
    header: __('Project'),
  },
};
</script>
<template>
  <div>
    <span class="gl-display-block gl-mb-4" data-testid="drawer-section-header">
      {{ $options.i18n.header }}
    </span>
    <div class="gl-display-flex gl-align-items-center">
      <gl-avatar-link :title="name" :href="url">
        <gl-avatar-labeled :size="16" :entity-name="name" label="" :sub-label="name" :src="avatarUrl" />
      </gl-avatar-link>
      <compliance-framework-label
        v-if="complianceFramework"
        class="gl-ml-3"
        :name="complianceFramework.name"
        :color="complianceFramework.color"
        :description="complianceFramework.description"
      />
    </div>
  </div>
</template>
