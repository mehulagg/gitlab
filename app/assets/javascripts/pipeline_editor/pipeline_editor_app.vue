<script>
import { GlLoadingIcon, GlAlert, GlTabs, GlTab } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import { redirectTo, mergeUrlParams, refreshCurrentPage } from '~/lib/utils/url_utility';

import TextEditor from './components/text_editor.vue';
import CommitForm from './components/commit/commit_form.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';
import commitCiFileMutation from './graphql/mutations/commit_ci_file.mutation.graphql';

import getBlobContent from './graphql/queries/blob_content.graphql';

const MR_SOURCE_BRANCH = 'merge_request[source_branch]';
const MR_TARGET_BRANCH = 'merge_request[target_branch]';

export default {
  components: {
    GlLoadingIcon,
    GlAlert,
    GlTabs,
    GlTab,
    TextEditor,
    CommitForm,
    PipelineGraph,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    defaultBranch: {
      type: String,
      required: false,
      default: null,
    },
    commitId: {
      type: String,
      required: false,
      default: null,
    },
    ciConfigPath: {
      type: String,
      required: true,
    },
    newMergeRequestPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      errorMessage: null,
      isSaving: false,
      editorIsReady: false,
      content: '',
      contentModel: '',
    };
  },
  apollo: {
    content: {
      query: getBlobContent,
      variables() {
        return {
          projectPath: this.projectPath,
          path: this.ciConfigPath,
          ref: this.defaultBranch,
        };
      },
      update(data) {
        return data?.blobContent?.rawData;
      },
      result({ data }) {
        this.contentModel = data?.blobContent?.rawData ?? '';
      },
      error(error) {
        this.handleBlobContentError(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.content.loading;
    },
    defaultCommitMessage() {
      return sprintf(this.$options.i18n.defaultCommitMessage, { sourcePath: this.ciConfigPath });
    },
    pipelineData() {
      // Note data will loaded as part of https://gitlab.com/gitlab-org/gitlab/-/issues/263141
      return {};
    },
  },
  i18n: {
    defaultCommitMessage: __('Update %{sourcePath} file'),
    tabEdit: s__('Pipelines|Write pipeline configuration'),
    tabGraph: s__('Pipelines|Visualize'),

    unknownError: __('Unknown Error'),
    fetchErrorMsg: s__('Pipelines|CI file could not be loaded: %{reason}'),
    commitErrorMsg: s__('Pipelines|CI file could not be saved: %{reason}'),
  },
  methods: {
    handleBlobContentError(error) {
      const { message: generalReason, networkError } = error;

      const { data } = networkError?.response ?? {};
      // 404 for missing file uses `message`
      // 400 for a missing ref uses `error`
      const networkReason = data?.message ?? data?.error;

      const reason = networkReason ?? generalReason ?? this.$options.i18n.unknownError;
      this.errorMessage = sprintf(this.$options.i18n.fetchErrorMsg, { reason });
    },
    redirectToNewMergeRequest(sourceBranch) {
      const url = mergeUrlParams(
        {
          [MR_SOURCE_BRANCH]: sourceBranch,
          [MR_TARGET_BRANCH]: this.defaultBranch,
        },
        this.newMergeRequestPath,
      );
      redirectTo(url);
    },
    async onCommitSubmit(event) {
      this.isSaving = true;
      const { message, branch, openMergeRequest } = event;

      try {
        const {
          data: {
            commitCreate: { errors },
          },
        } = await this.$apollo.mutate({
          mutation: commitCiFileMutation,
          variables: {
            projectPath: this.projectPath,
            branch,
            startBranch: this.defaultBranch,
            message,
            filePath: this.ciConfigPath,
            content: this.contentModel,
            lastCommitId: this.commitId,
          },
        });

        if (errors?.length) {
          throw new Error(errors[0]);
        }

        if (openMergeRequest) {
          this.redirectToNewMergeRequest(branch);
        } else {
          // Refresh the page to ensure commit is updated
          refreshCurrentPage();
        }
      } catch (error) {
        const reason = error?.message || this.$options.i18n.unknownError;
        this.errorMessage = sprintf(this.$options.i18n.commitErrorMsg, { reason });
      } finally {
        this.isSaving = false;
      }
    },
    onCommitCancel() {
      this.contentModel = this.content;
    },
    onErrorDismiss() {
      this.errorMessage = null;
    },
  },
};
</script>

<template>
  <div class="gl-mt-4">
    <gl-alert v-if="errorMessage" variant="danger" :dismissible="true" @dismiss="onErrorDismiss">
      {{ errorMessage }}
    </gl-alert>
    <div class="gl-mt-4">
      <gl-loading-icon v-if="isLoading" size="lg" class="gl-m-3" />
      <div v-else class="file-editor gl-mb-3">
        <gl-tabs>
          <!-- editor should be mounted when its tab is visible, so the container has a size -->
          <gl-tab :title="$options.i18n.tabEdit" :lazy="!editorIsReady">
            <!-- editor should be mounted only once, when the tab is displayed -->
            <text-editor v-model="contentModel" @editor-ready="editorIsReady = true" />
          </gl-tab>

          <gl-tab :title="$options.i18n.tabGraph">
            <pipeline-graph :pipeline-data="pipelineData" />
          </gl-tab>
        </gl-tabs>
      </div>
      <commit-form
        :default-branch="defaultBranch"
        :default-message="defaultCommitMessage"
        :is-saving="isSaving"
        @cancel="onCommitCancel"
        @submit="onCommitSubmit"
      />
    </div>
  </div>
</template>
