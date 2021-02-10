<script>
/* eslint-disable vue/no-v-html */
import { GlButton } from '@gitlab/ui';
import emptyStateSVG from 'icons/_mr_widget_empty_state.svg';

export default {
  name: 'MRWidgetNothingToMerge',
  components: {
    GlButton,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
  data() {
    return { emptyStateSVG };
  },
};
</script>

<template>
  <div class="mr-widget-body mr-widget-empty-state">
    <div class="row">
      <div
        class="artwork col-md-5 order-md-last col-12 text-center d-flex justify-content-center align-items-center"
      >
        <span v-html="emptyStateSVG"></span>
      </div>
      <div class="text col-md-7 order-md-first col-12">
        <p class="highlight">
          {{
            s__(
              'mrWidgetNothingToMerge|This merge request contains no changes.',
            )
          }}
        </p>
        <p>
          {{
            s__(
              'mrWidgetNothingToMerge|Use merge requests to propose changes to your project and discuss those changes with your team. To make changes to files, push a new commit or update the merge request to use a different branch.',
            )
          }}
        </p>
        <div>
          <gl-button
            v-if="mr.newBlobPath"
            :href="mr.newBlobPath"
            category="secondary"
            variant="success"
          >
            {{ __('Create file') }}
          </gl-button>
        </div>
      </div>
    </div>
  </div>
</template>
