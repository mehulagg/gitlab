<script>
import {
  GlModal,
  GlForm,
  GlFormCheckbox,
  GlSprintf,
  GlDropdown,
  GlSearchBoxByType,
  GlDropdownItem,
  GlFormGroup,
} from '@gitlab/ui';
import eventHub from '../event_hub';
import { s__, __ } from '~/locale';
import { OPEN_MODAL, MODAL_ID } from '../constants';
import csrf from '~/lib/utils/csrf';

// const events = {
//   selectBranch: 'selectBranch',
// };

export default {
  actionCancel: {
    text: __('Cancel'),
  },
  actionPrimary: {
    text: __('Revert'),
  },
  okTitle: __('Revert'),
  modalId: MODAL_ID,
  components: {
    GlModal,
    GlForm,
    GlFormCheckbox,
    GlSprintf,
    GlDropdown,
    GlSearchBoxByType,
    GlDropdownItem,
    GlFormGroup,
  },
  inject: {
    title: {
      default: '',
    },
    path: {
      default: '',
    },
    startBranch: {
      default: '',
    },
    targetBranch: {
      default: '',
    },
  },
  props: {
    pushCode: {
      type: Boolean,
      required: false,
      default: false,
    },
    branchCollaboration: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  i18n: {
    startMergeRequest: __('Start a %{newMergeRequest} with these changes'),
    existingBranch: __(
      'Your changes can be committed to %{branchName} because a merge request is open.',
    ),
    branchInFork: __(
      'A new branch will be created in your fork and a new merge request will be started.',
    ),
    branchLabel: s__('ChangeTypeActionLabel|Revert in branch'),
    noResultsMessage: __('Nothing found...'),
  },
  data() {
    return {
      checked: true,
      newMergeRequest: __('new merge request'),
      branchName: this.targetBranch,
      searchTerm: '',
      selectedBranch: this.startBranch,
    };
  },
  computed: {
    branchNames() {
      return ['ABC', '123'];
    },
    shouldShowNoMsgContainer() {
      return this.branchNames.length === 0;
    },
  },
  mounted() {
    eventHub.$on(OPEN_MODAL, this.openModal);
  },
  methods: {
    openModal() {
      this.$root.$emit('bv::show::modal', MODAL_ID);
    },
    handlePrimary() {
      this.$refs.form.$el.submit();
    },
    selectBranch(branch) {
      this.selectedBranch = branch;
    },
  },
  csrf,
};
</script>
<template>
  <gl-modal
    :modal-id="$options.modalId"
    size="sm"
    :title="title"
    :action-cancel="$options.actionCancel"
    :action-primary="$options.actionPrimary"
    @primary="handlePrimary"
  >
    <gl-form ref="form" :action="path" method="post">
      <input type="hidden" name="authenticity_token" :value="$options.csrf.token" />

      <gl-form-group :label="$options.i18n.branchLabel" label-for="start_branch">
        <input id="start_branch" type="hidden" name="start_branch" :value="selectedBranch"/>

        <gl-dropdown :text="selectedBranch" header-text="Switch branch">
          <gl-search-box-by-type v-model.trim="searchTerm" />
          <gl-dropdown-item v-for="branch in branchNames" :key="branch" @click="selectBranch(branch)">
            {{ branch }}
          </gl-dropdown-item>
          <div v-show="shouldShowNoMsgContainer" class="text-secondary p-2">
            {{ $options.i18n.noResultsMessage }}
          </div>
        </gl-dropdown>
      </gl-form-group>

      <gl-form-checkbox v-if="pushCode" v-model="checked" class="gl-mt-3">
        <gl-sprintf :message="$options.i18n.startMergeRequest">
          <template #newMergeRequest>
            <strong>{{ newMergeRequest }}</strong>
          </template>
        </gl-sprintf>
      </gl-form-checkbox>

      <input v-else type="hidden" name="create_merge_request" value="1" />
      <p v-if="!pushCode" class="gl-mb-0 gl-mt-5">
        <gl-sprintf v-if="branchCollaboration" :message="$options.i18n.existingBranch">
          <template #branchName>
            <strong>{{ branchName }}</strong>
          </template>
        </gl-sprintf>
        <gl-sprintf v-else :message="$options.i18n.branchInFork" />
      </p>
    </gl-form>
  </gl-modal>
</template>
