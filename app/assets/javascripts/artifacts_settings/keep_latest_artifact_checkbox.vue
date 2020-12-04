<script>
import { GlFormCheckbox, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlFormCheckbox,
    GlLink,
  },
  data() {
    return {
      checked: true,
    };
  },
};
</script>

<template>
  <div>
    <gl-form-checkbox v-model="checked"
      ><b class="gl-mr-3">{{ __('Keep latest artifacts from last successful jobs') }}</b>
      <gl-link href="https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html">{{
        __('More information')
      }}</gl-link></gl-form-checkbox
    >
    <p>
      {{
        __(
          'The latest artifacts created by jobs in the most recent successful pipeline will be stored.',
        )
      }}
    </p>
  </div>
</template>
