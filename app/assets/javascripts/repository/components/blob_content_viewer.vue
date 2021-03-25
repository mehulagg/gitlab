<script>
import { GlLoadingIcon } from '@gitlab/ui';
import BlobContent from '~/blob/components/blob_content.vue';
import BlobHeader from '~/blob/components/blob_header.vue';
import { redirectTo } from '~/lib/utils/url_utility';

export default {
  components: {
    BlobHeader,
    BlobContent,
    GlLoadingIcon,
  },
  provide() {
    return {
      blobHash: Math.random().toString().split('.')[1],
    };
  },
  data() {
    return {
      blobMock: {
        rawPath: 'raw/path/to/file.js',
        path: 'path/to/file.js',
        name: 'file.js',
        rawBlob: `$(function test() {} // Test)`,
        size: 1234,
        fileType: 'text',
        tooLarge: false,
        type: 'simple',
      },
      loading: false,
    };
  },
  computed: {
    hasClientViewer() {
      // For now we only support 'text' file types on the client
      // As we rollout the repo browser refactor, we'll add support for more and eventually remove this check.
      // Follow the Epic for more: https://gitlab.com/groups/gitlab-org/-/epics/5531
      return this.viewer.fileType === 'text';
    },
    viewer() {
      return {
        fileType: this.blobMock.fileType,
        tooLarge: this.blobMock.tooLarge,
        type: this.blobMock.type,
      };
    },
  },
  created() {
    if (!this.hasClientViewer) {
      // fallback to the haml viewer if there is not a client viewer for the fileType
      // the rails router checks 'noClientViewer' param and routes to haml
      this.loading = true;
      redirectTo('?noClientViewer=true');
    }
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="loading" />
    <div v-else>
      <blob-header :blob="blobMock" />
      <blob-content
        :blob="blobMock"
        :content="blobMock.rawBlob"
        :active-viewer="viewer"
        :loading="false"
      />
    </div>
  </div>
</template>
