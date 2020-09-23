<script>
import { GlButton, GlEmptyState, GlLink, GlSprintf } from '@gitlab/ui';

export default {
  name: 'OnDemandScansEmptyState',
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
    GlSprintf,
  },
  props: {
    helpPagePath: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-empty-state :svg-path="emptyStateSvgPath" :title="s__('OnDemandScans|On-demand Scans')">
      <template #description>
        <gl-sprintf
          :message="
            s__(
              'OnDemandScans|Schedule or run scans immediately against target sites. Currently available on-demand scan type: DAST. %{helpLinkStart}More information%{helpLinkEnd}',
            )
          "
        >
          <template #helpLink="{ content }">
            <gl-link :href="helpPagePath">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </template>
      <template #actions>
        <gl-button data-testid="run-scan-button" variant="success" @click="$emit('createNewScan')">
          {{ s__('OnDemandScans|Create new DAST scan') }}
        </gl-button>
      </template>
    </gl-empty-state>
  </div>
</template>
