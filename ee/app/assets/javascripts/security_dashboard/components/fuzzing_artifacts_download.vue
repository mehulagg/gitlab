<script>
import { GlButton, GlDropdown, GlDeprecatedDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  i18n: {
    FUZZING_ARTIFACTS: s__('SecurityReports|Fuzzing artifacts'),
  },
  components: {
    GlButton,
    GlDropdown,
    GlDeprecatedDropdownItem,
  },
  props: {
    jobs: {
      type: Array,
      required: true,
    },
    projectId: {
      type: Number,
      required: true,
    },
  },
  computed: {
    hasDropdown() {
      return this.jobs.length > 1;
    },
  },
  methods: {
    artifactDownloadUrl(job) {
      return `/api/v4/projects/${this.projectId}/jobs/artifacts/${
        job.ref
      }/download?job=${encodeURIComponent(job.name)}`;
    },
  },
};
</script>

<template>
  <div>
    <slot name="label"></slot>
    <gl-dropdown
      v-if="hasDropdown"
      class="d-block mt-1"
      :text="$options.i18n.FUZZING_ARTIFACTS"
      category="secondary"
      size="small"
    >
      <gl-deprecated-dropdown-item
        v-for="job in jobs"
        :key="job.id"
        :href="artifactDownloadUrl(job)"
        >{{ job.name }}</gl-deprecated-dropdown-item
      >
    </gl-dropdown>
    <gl-button
      v-else
      class="d-block mt-1"
      category="secondary"
      size="small"
      :href="artifactDownloadUrl(jobs[0])"
    >
      {{ $options.i18n.FUZZING_ARTIFACTS }}
    </gl-button>
  </div>
</template>
