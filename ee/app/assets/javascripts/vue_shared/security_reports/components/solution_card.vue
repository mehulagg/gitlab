<script>
import { GlIcon } from '@gitlab/ui';
import { setUrlFragment } from '~/lib/utils/url_utility';

export default {
  name: 'SolutionCard',
  components: { GlIcon },
  props: {
    solution: {
      type: String,
      default: '',
      required: false,
    },
    remediation: {
      type: Object,
      default: null,
      required: false,
    },
    hasDownload: {
      type: Boolean,
      default: false,
      required: false,
    },
    hasMr: {
      type: Boolean,
      default: false,
      required: false,
    },
    vulnerabilityFeedbackHelpPath: {
      type: String,
      default: '',
      required: false,
    },
    isStandaloneVulnerability: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    solutionText() {
      return (this.remediation && this.remediation.summary) || this.solution;
    },
    helpPath() {
      return setUrlFragment(
        this.vulnerabilityFeedbackHelpPath,
        'solutions-for-vulnerabilities-auto-remediation',
      );
    },
    showCreateMergeRequestMsg() {
      return !this.hasMr && Boolean(this.remediation) && this.hasDownload;
    },
    showLearnAboutRemedationMsg() {
      return !this.hasMr;
    },
    showMsg() {
      return (
        this.vulnerabilityFeedbackHelpPath &&
        (this.showCreateMergeRequestMsg || this.showLearnAboutRemedationMsg)
      );
    },
  },
};
</script>
<template>
  <div class="card my-4">
    <div v-if="solutionText" class="card-body d-flex align-items-center">
      <div
        class="col-auto d-flex align-items-center pl-0"
        :class="{ 'col-md-2': !isStandaloneVulnerability }"
      >
        <div class="circle-icon-container pr-3" aria-hidden="true"><gl-icon name="bulb" /></div>
        <strong class="text-right flex-grow-1">{{ s__('ciReport|Solution') }}:</strong>
      </div>
      <span class="flex-shrink-1 pl-0" :class="{ 'col-md-10': !isStandaloneVulnerability }">{{
        solutionText
      }}</span>
    </div>
    <template v-if="showMsg">
      <div class="card-footer" :class="{ 'border-0': !solutionText }">
        <em class="text-secondary">
          <template v-if="showCreateMergeRequestMsg">
            {{
              s__(
                'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
              )
            }}
          </template>

          <a
            v-if="showLearnAboutRemedationMsg"
            :href="helpPath"
            class="js-link-vulnerabilityFeedbackHelpPath"
          >
            {{ s__('ciReport|Learn more about interacting with security reports') }}
            <gl-icon :size="16" name="external-link" class="align-text-top" />
          </a>
        </em>
      </div>
    </template>
  </div>
</template>
