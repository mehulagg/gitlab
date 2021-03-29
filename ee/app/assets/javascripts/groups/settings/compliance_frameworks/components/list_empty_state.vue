<script>
import { GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
  },
  props: {
    imagePath: {
      type: String,
      required: true,
    },
    addFrameworkPath: {
      type: String,
      required: true,
    },
    canManageComplianceFrameworks: {
      type: Boolean,
      required: true
    }
  },
  i18n: {
    heading: s__('ComplianceFrameworks|There are no compliance frameworks set up yet'),
    description: s__(
      'ComplianceFrameworks|Once you have created a compliance framework it will appear here.',
    ),
    addButton: s__('ComplianceFrameworks|Add framework'),
  },
  computed: {
    computedFrameworkPath: function addFrameworkPath() {
      if (this.canManageComplianceFrameworks) {
        return this.addFrameworkPath
      }
      return null
    }
  }
};
</script>

<template>
  <gl-empty-state
    :title="$options.i18n.heading"
    :description="$options.i18n.description"
    :svg-path="imagePath"
    :primary-button-link="computedFrameworkPath"
    :primary-button-text="$options.i18n.addButton"
    compact
    :svg-height="110"
    class="gl-mt-5"
  />
</template>
