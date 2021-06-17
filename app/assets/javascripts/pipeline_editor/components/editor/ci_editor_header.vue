<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import Tracking from '~/tracking';
import { pipelineEditorTrackingOptions } from '../../constants';

export default {
  i18n: {
    browseTemplates: __('Browse templates'),
  },
  components: {
    GlButton,
  },
  mixins: [Tracking.mixin()],
  methods: {
    trackTemplateBrowsing() {
      const { label, actions } = pipelineEditorTrackingOptions;

      this.track(actions.browse_templates, { label });
    },
  },
};
</script>

<template>
  <div class="gl-bg-gray-10 gl-p-3 gl-border-solid gl-border-gray-50 gl-border-1">
    <gl-button
      href="https://gitlab.com/gitlab-org/gitlab-foss/tree/master/lib/gitlab/ci/templates"
      size="small"
      icon="external-link"
      target="_blank"
      @click="trackTemplateBrowsing"
    >
      {{ $options.i18n.browseTemplates }}
    </gl-button>
  </div>
</template>
