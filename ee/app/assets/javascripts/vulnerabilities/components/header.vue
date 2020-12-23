<script>
import { GlLoadingIcon, GlButton, GlBadge } from '@gitlab/ui';
import Api from 'ee/api';
import { CancelToken } from 'axios';
import SplitButton from 'ee/vue_shared/security_reports/components/split_button.vue';
import vulnerabilityStateMutations from 'ee/security_dashboard/graphql/mutate_vulnerability_state';
import axios from '~/lib/utils/axios_utils';
import download from '~/lib/utils/downloader';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { redirectTo } from '~/lib/utils/url_utility';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__ } from '~/locale';
import UsersCache from '~/lib/utils/users_cache';
import ResolutionAlert from './resolution_alert.vue';
import VulnerabilityStateDropdown from './vulnerability_state_dropdown.vue';
import StatusDescription from './status_description.vue';
import { VULNERABILITY_STATE_OBJECTS, FEEDBACK_TYPES, HEADER_ACTION_BUTTONS } from '../constants';

const gidPrefix = 'gid://gitlab/Vulnerability/';

export default {
  name: 'VulnerabilityHeader',

  components: {
    GlLoadingIcon,
    GlButton,
    GlBadge,
    ResolutionAlert,
    VulnerabilityStateDropdown,
    SplitButton,
    StatusDescription,
  },

  props: {
    initialVulnerability: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      isProcessingAction: false,
      isLoadingVulnerability: false,
      isLoadingUser: false,
      // Spread operator because the header could modify the `project`
      // prop leading to an error in the footer component.
      vulnerability: { ...this.initialVulnerability },
      user: undefined,
      refreshVulnerabilitySource: undefined,
    };
  },

  badgeVariants: {
    confirmed: 'danger',
    resolved: 'success',
    detected: 'warning',
  },

  computed: {
    stateVariant() {
      return this.$options.badgeVariants[this.vulnerability.state] || 'neutral';
    },
    actionButtons() {
      const buttons = [];

      if (this.canCreateMergeRequest) {
        buttons.push(HEADER_ACTION_BUTTONS.mergeRequestCreation);
      }

      if (this.canDownloadPatch) {
        buttons.push(HEADER_ACTION_BUTTONS.patchDownload);
      }

      return buttons;
    },
    canDownloadPatch() {
      return (
        this.vulnerability.state !== VULNERABILITY_STATE_OBJECTS.resolved.state &&
        !this.vulnerability.hasMr &&
        this.hasRemediation
      );
    },
    hasIssue() {
      return Boolean(this.vulnerability.issueFeedback?.issueIid);
    },
    hasRemediation() {
      const { remediations } = this.vulnerability;
      return Boolean(remediations && remediations[0]?.diff?.length > 0);
    },
    canCreateMergeRequest() {
      return (
        !this.vulnerability.mergeRequestFeedback?.mergeRequestPath &&
        Boolean(this.vulnerability.createMrUrl) &&
        this.hasRemediation
      );
    },
    showResolutionAlert() {
      return (
        this.vulnerability.resolvedOnDefaultBranch &&
        this.vulnerability.state !== VULNERABILITY_STATE_OBJECTS.resolved.state
      );
    },
  },

  watch: {
    'vulnerability.state': {
      immediate: true,
      handler(state) {
        const id = this.vulnerability[`${state}ById`];

        if (!id) {
          return;
        }

        this.isLoadingUser = true;

        UsersCache.retrieveById(id)
          .then((userData) => {
            this.user = userData;
          })
          .catch(() => {
            createFlash(s__('VulnerabilityManagement|Something went wrong, could not get user.'));
          })
          .finally(() => {
            this.isLoadingUser = false;
          });
      },
    },
  },

  methods: {
    triggerClick(action) {
      const fn = this[action];
      if (typeof fn === 'function') fn();
    },

    async changeVulnerabilityState({ action, payload }) {
      this.isLoadingVulnerability = true;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: vulnerabilityStateMutations[action],
          variables: { id: `${gidPrefix}${this.vulnerability.id}`, ...payload },
        });
        const [queryName] = Object.keys(data);
        const { vulnerability } = data[queryName];
        vulnerability.id = vulnerability.id.replace(gidPrefix, '');
        vulnerability.state = vulnerability.state.toLowerCase();

        this.vulnerability = {
          ...this.vulnerability,
          ...vulnerability,
        };

        this.$emit('vulnerability-state-change');
      } catch (error) {
        createFlash({
          error,
          captureError: true,
          message: s__(
            'VulnerabilityManagement|Something went wrong, could not update vulnerability state.',
          ),
        });
      } finally {
        this.isLoadingVulnerability = false;
      }
    },

    createMergeRequest() {
      this.isProcessingAction = true;

      const {
        reportType: category,
        pipeline: { sourceBranch },
        projectFingerprint,
      } = this.vulnerability;

      axios
        .post(this.vulnerability.createMrUrl, {
          vulnerability_feedback: {
            feedback_type: FEEDBACK_TYPES.MERGE_REQUEST,
            category,
            project_fingerprint: projectFingerprint,
            vulnerability_data: {
              ...convertObjectPropsToSnakeCase(this.vulnerability),
              category,
              target_branch: sourceBranch,
            },
          },
        })
        .then(({ data: { merge_request_path: mergeRequestPath } }) => {
          redirectTo(mergeRequestPath);
        })
        .catch(() => {
          this.isProcessingAction = false;
          createFlash(
            s__('ciReport|There was an error creating the merge request. Please try again.'),
          );
        });
    },
    downloadPatch() {
      download({
        fileData: this.vulnerability.remediations[0].diff,
        fileName: `remediation.patch`,
      });
    },
    refreshVulnerability() {
      this.isLoadingVulnerability = true;

      // Cancel any pending API requests.
      if (this.refreshVulnerabilitySource) {
        this.refreshVulnerabilitySource.cancel();
      }

      this.refreshVulnerabilitySource = CancelToken.source();

      Api.fetchVulnerability(this.vulnerability.id, {
        cancelToken: this.refreshVulnerabilitySource.token,
      })
        .then(({ data }) => {
          Object.assign(this.vulnerability, data);
        })
        .catch((e) => {
          // Don't show an error message if the request was cancelled through the cancel token.
          if (!axios.isCancel(e)) {
            createFlash(
              s__(
                'VulnerabilityManagement|Something went wrong while trying to refresh the vulnerability. Please try again later.',
              ),
            );
          }
        })
        .finally(() => {
          this.isLoadingVulnerability = false;
          this.refreshVulnerabilitySource = undefined;
        });
    },
  },
};
</script>

<template>
  <div data-qa-selector="vulnerability_header">
    <resolution-alert
      v-if="showResolutionAlert"
      :vulnerability-id="vulnerability.id"
      :default-branch-name="vulnerability.projectDefaultBranch"
    />
    <div class="detail-page-header">
      <div class="detail-page-header-body align-items-center">
        <gl-loading-icon v-if="isLoadingVulnerability" class="mr-2" />
        <gl-badge v-else class="gl-mr-4 text-capitalize" :variant="stateVariant">
          {{ vulnerability.state }}
        </gl-badge>

        <status-description
          class="issuable-meta"
          :vulnerability="vulnerability"
          :user="user"
          :is-loading-vulnerability="isLoadingVulnerability"
          :is-loading-user="isLoadingUser"
        />
      </div>

      <div class="detail-page-header-actions align-items-center">
        <label class="mb-0 mx-2">{{ __('Status') }}</label>
        <gl-loading-icon v-if="isLoadingVulnerability" class="d-inline" />
        <vulnerability-state-dropdown
          v-else
          :initial-state="vulnerability.state"
          @change="changeVulnerabilityState"
        />
        <split-button
          v-if="actionButtons.length > 1"
          :buttons="actionButtons"
          :disabled="isProcessingAction"
          class="js-split-button"
          @createMergeRequest="createMergeRequest"
          @downloadPatch="downloadPatch"
        />
        <gl-button
          v-else-if="actionButtons.length > 0"
          class="ml-2"
          variant="success"
          category="secondary"
          :loading="isProcessingAction"
          @click="triggerClick(actionButtons[0].action)"
        >
          {{ actionButtons[0].name }}
        </gl-button>
      </div>
    </div>
  </div>
</template>
