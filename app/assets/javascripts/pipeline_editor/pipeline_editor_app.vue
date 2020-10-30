<script>
import { GlLoadingIcon, GlAlert, GlTabs, GlTab } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';

import TextEditor from './components/text_editor.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';

import getBlobContent from './graphql/queries/blob_content.graphql';

export default {
  components: {
    GlLoadingIcon,
    GlAlert,
    GlTabs,
    GlTab,
    TextEditor,
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
    ciConfigPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      error: null,
      content: '',
      editorReady: false,
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
      error(error) {
        this.error = error;
      },
    },
  },
  computed: {
    loading() {
      return this.$apollo.queries.content.loading;
    },
    errorMessage() {
      const { message, networkError } = this.error ?? {};

      let reason = message ?? this.$options.i18n.unknownMessage;

      if (networkError && networkError.response) {
        const { data = {} } = networkError.response;
        // 400 for a missing ref uses `error`
        // 404 for missing file uses `message`
        reason = data.message ?? data.error ?? reason;
      }

      return sprintf(this.$options.i18n.errorMessageWithReason, { reason });
    },
    pipelineData() {
      return {
        stages: [
          {
            name: 'test',
            groups: [
              {
                id: '10',
                name: 'jest',
                size: 2,
                jobs: [{ id: '100', name: 'jest 1/2' }, { id: '101', name: 'jest 2/2' }],
              },
              {
                id: '11',
                name: 'rspec',
                size: 1,
                jobs: [{ id: '110', name: 'rspec' }],
              },
            ],
          },
          {
            name: 'post-test',
            groups: [
              {
                id: '20',
                name: 'jest-coverage',
                size: 1,
                jobs: [{ id: '200', name: 'jest-coverage', needs: ['jest'] }],
              },
            ],
          },
        ],
      };
    },
  },
  i18n: {
    unknownMessage: __('Unknown Error'),
    errorMessageWithReason: s__('Pipelines|CI file could not be loaded: %{reason}'),
    tabEdit: s__('Pipelines|Write pipeline configuration'),
    tabGraph: s__('Pipelines|Visualize'),
  },
};
</script>

<template>
  <div class="gl-mt-4">
    <gl-alert v-if="error" :dismissible="false" variant="danger">{{ errorMessage }}</gl-alert>
    <div class="gl-mt-4">
      <gl-loading-icon v-if="loading" size="lg" />
      <div v-else class="file-editor">
        <gl-tabs nav-class="nav-links">
          <gl-tab :title="$options.i18n.tabEdit" :lazy="!editorReady">
            <text-editor v-model="content" @editor-ready="editorReady = true" />
          </gl-tab>
          <gl-tab :title="$options.i18n.tabGraph">
            <keep-alive>
              <pipeline-graph :pipeline-data="pipelineData" />
            </keep-alive>
          </gl-tab>
        </gl-tabs>
      </div>
    </div>
  </div>
</template>
