<script>
import statusIcon from '../mr_widget_status_icon.vue';
import { GlLink, GlIcon } from '@gitlab/ui';

export default {
  name: 'PipelineFailed',
  components: {
    statusIcon,
    GlLink,
    GlIcon,
  },
};
</script>

<template>
  <div class="mr-widget-body media">
    <status-icon :show-disabled-button="true" status="warning" />
    <div class="media-body space-children">
      <span class="bold">
        {{
          s__(
            `mrWidget|The pipeline for this merge request did not complete. Push a new commit to fix the failure or refer to documentation to see the recommended action based on the pipeline type.`,
          )
        }}
        <gl-link class="gl-ml-2" href="" target="_blank">
          <gl-icon name="question" />
        </gl-link>
      </span>
    </div>
  </div>
</template>
