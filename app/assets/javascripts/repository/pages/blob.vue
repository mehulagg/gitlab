<script>
// This file is in progress and behind a feature flag, please see the following issue for more:
// https://gitlab.com/gitlab-org/gitlab/-/issues/323200

import BlobContentViewer from '../components/blob_content_viewer.vue';
import BlobNavBlock from '../components/blob_nav_block.vue';

export default {
  components: {
    BlobContentViewer,
    BlobNavBlock,
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
    findFilePath: {
      type: String,
      required: true,
    },
    blamePath: {
      type: String,
      required: true,
    },
    historyPath: {
      type: String,
      required: true,
    },
    permalinkPath: {
      type: String,
      required: true,
    },
    readableText: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
};
</script>

<template>
  <div>
    <blob-nav-block
      :find-file-path="findFilePath"
      :blame-path="blamePath"
      :history-path="historyPath"
      :permalink-path="permalinkPath"
      :readableText="readableText"
    />
    <blob-content-viewer :path="path" :project-path="projectPath" />
  </div>
</template>
