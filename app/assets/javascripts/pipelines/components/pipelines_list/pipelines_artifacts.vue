<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import { GlDropdown, GlDropdownItem, GlLink, GlTooltipDirective, GlIcon } from '@gitlab/ui';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlIcon,
    GlLink,
  },
  props: {
    artifacts: {
      type: Array,
      required: true,
    },
  },
};
</script>
<template>
  <gl-dropdown
    v-gl-tooltip
    type="button"
    class="build-artifacts js-pipeline-dropdown-download"
    :title="__('Artifacts')"
    :text="__('Artifacts')"
    :aria-label="__('Artifacts')"
    icon="download"
    text-sr-only
  >
    <gl-dropdown-item
      v-for="(artifact, i) in artifacts"
      :key="i"
      :href="artifact.path"
      rel="nofollow"
      download
      >Download {{ artifact.name }} artifact</gl-dropdown-item
    >
  </gl-dropdown>
</template>
