<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import BlobContent from '~/blob/components/blob_content.vue';
import BlobHeader from '~/blob/components/blob_header.vue';
import { SIMPLE_BLOB_VIEWER, RICH_BLOB_VIEWER } from '~/blob/components/constants';
import createFlash from '~/flash';
import { __ } from '~/locale';
import blobInfoQuery from '../queries/blob_info.query.graphql';

export default {
  components: {
    BlobHeader,
    BlobContent,
    GlLoadingIcon,
  },
  apollo: {
    project: {
      query: blobInfoQuery,
      variables() {
        return {
          projectPath: this.projectPath,
          filePath: this.path,
        };
      },
      error() {
        createFlash({ message: __('An error occurred while loading the file. Please try again.') });
      },
    },
  },
  provide() {
    return {
      blobHash: uniqueId(),
    };
  },
  props: {
    path: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    hasRichViewer: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      activeViewerType:
        this.hasRichViewer && !window.location.hash ? RICH_BLOB_VIEWER : SIMPLE_BLOB_VIEWER,
      project: {
        repository: {
          blobs: {
            nodes: [
              {
                name: '',
                size: '',
                rawTextBlob: '',
                type: '',
                fileType: '',
                tooLarge: false,
                path: '',
                editBlobPath: '',
                ideEditPath: '',
                storedExternally: false,
                rawPath: '',
                externalStorageUrl: '',
                replacePath: '',
                deletePath: '',
                canLock: false,
                isLocked: false,
                lockLink: '',
                canModifyBlob: true,
                forkPath: '',
                simpleViewer: {},
                richViewer: {},
              },
            ],
          },
        },
      },
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.project.loading;
    },
    blobInfo() {
      const nodes = this.project?.repository?.blobs?.nodes;

      return nodes[0] || {};
    },
    viewer() {
      const { richViewer, simpleViewer } = this.blobInfo;
      return this.activeViewerType === RICH_BLOB_VIEWER ? richViewer : simpleViewer;
    },
    hasRenderError() {
      return Boolean(this.viewer.renderError);
    },
  },
  methods: {
    switchViewer(newViewer) {
      this.activeViewerType = newViewer || SIMPLE_BLOB_VIEWER;
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" />
    <div class="file-holder" v-if="blobInfo && !isLoading">
      <blob-header
        :blob="blobInfo"
        :hideViewerSwitcher="!hasRichViewer"
        :active-viewer-type="viewer.type"
        :has-render-error="hasRenderError"
        @viewer-changed="switchViewer"
      />
      <blob-content
        :blob="blobInfo"
        :content="blobInfo.rawTextBlob"
        :is-raw-content="true"
        :active-viewer="viewer"
        :loading="false"
      />
    </div>
  </div>
</template>
