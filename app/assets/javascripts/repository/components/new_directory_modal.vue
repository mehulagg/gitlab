<script>
import {
  GlModal,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
  GlFormCheckbox,
  GlSprintf,
} from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';

export default {
  components: { GlModal, GlFormGroup, GlFormInput, GlFormTextarea, GlFormCheckbox, GlSprintf },
  props: {
    newDirPath: {
      type: String,
      required: true,
    },
    emptyRepo: {
      type: String,
      required: true,
    },
    selectedBranch: {
      type: String,
      required: true,
    },
    originalBranch: {
      type: String,
      required: true,
    },
    branchAllowsCollaboration: {
      type: String,
      required: true,
    },
    canPushCode: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      directoryName: '',
      commitMessage: '',
      branchName: this.selectedBranch,
      createMergeRequest: true,
    };
  },
  computed: {
    canPushToBranch() {
      // TODO: How do we update this when branchName changes?
      // project.can_current_user_push_to_branch?(branch_name) - PROP.can_push_to_branch
      return false;
    },
  },
  methods: {
    handleSubmit() {
      axios.post(this.newDirPath);
    },
  },
  i18n: {
    directoryNameLabel: __('Directory name'),
    commitMessageLabel: __('Commit message'),
    commitMessagePlaceholder: __('Add new directory'),
    branchNameLabel: __('Target Branch'),
    createMergeRequestLabel: __('new merge request'),
    commitInForkHelp: __(
      'A new branch will be created in your fork and a new merge request will be started.',
    ),
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    :ok-title="__('Create directory')"
    modal-id="new-directory-modal"
    :title="__('Create New Directory')"
  >
    <form @submit.prevent>
      <gl-form-group
        label-cols-sm="2"
        label-for="dir_name"
        :label="$options.i18n.directoryNameLabel"
      >
        <gl-form-input id="dir_name" v-model="directoryName" required />
      </gl-form-group>

      <gl-form-group
        label-cols-sm="2"
        label-for="commit_message"
        :label="$options.i18n.commitMessageLabel"
      >
        <gl-form-textarea
          id="commit_message"
          v-model="commitMessage"
          :placeholder="$options.i18n.commitMessagePlaceholder"
          rows="3"
          required
        />
      </gl-form-group>

      <template v-if="emptyRepo">
        <input type="hidden" name="branch_name" :value="originalBranch" />
      </template>
      <template v-else>
        <gl-form-group
          v-if="canPushCode"
          label-cols-sm="2"
          label-for="branch_name"
          :label="$options.i18n.branchNameLabel"
        >
          <gl-form-input id="branch_name" v-model="branchName" required />
          <gl-form-checkbox id="create_merge_request" v-model="createMergeRequest" class="gl-mt-3">
            <gl-sprintf message="Start a %{content} with these changes">
              <template #content>
                <b>{{ $options.i18n.createMergeRequestLabel }}</b>
              </template>
            </gl-sprintf>
          </gl-form-checkbox>
        </gl-form-group>

        <template v-else>
          <input type="hidden" name="branch_name" :value="branchName" />
          <input
            v-if="!canPushToBranch"
            type="hidden"
            name="create_merge_request"
            :value="createMergeRequest"
          />
        </template>
      </template>
      <input type="hidden" name="original_branch" :value="originalBranch" />
      <div v-if="!canPushCode" class="gl-ml-3">
        <gl-sprintf
          v-if="branchAllowsCollaboration"
          message="Your changes can be committed to %{branchName} because a merge request is open."
        >
          <template #branchName>
            <b>{{ branchName }}</b>
          </template>
        </gl-sprintf>
        <span v-else>{{ commitInForkHelp }}</span>
      </div>
    </form>
  </gl-modal>
</template>
