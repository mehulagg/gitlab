<script>
import { GlLoadingIcon } from '@gitlab/ui';

import BlobContent from '~/blob/components/blob_content.vue';
import BlobHeader from '~/blob/components/blob_header.vue';

import {
  SIMPLE_BLOB_VIEWER,
  RICH_BLOB_VIEWER,
  BLOB_RENDER_EVENT_LOAD,
  BLOB_RENDER_EVENT_SHOW_SOURCE,
} from '~/blob/components/constants';

import getRefMixin from '../mixins/get_ref';
import blobRawQuery from '../queries/blob_raw.query.graphql';
import projectPathQuery from '../queries/project_path.query.graphql';

const LIMIT = 1000;
const PAGE_SIZE = 100;
export const INITIAL_FETCH_COUNT = LIMIT / PAGE_SIZE;

export default {
  components: { GlLoadingIcon, BlobContent, BlobHeader },
  mixins: [getRefMixin],
  apollo: {
    projectPath: {
      query: projectPathQuery,
    },
    blobRaw: {
      query: blobRawQuery,
      variables() {
        return {
          path: `/${this.projectPath}/-/raw/${this.ref}/${this.path}`,
        };
      },
    },
  },
  props: {
    path: {
      type: String,
      required: false,
      default: '/',
    },
    loadingPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      projectPath: '',
      blobInfo: {},
      blobRaw: null,
      activeViewerType: RICH_BLOB_VIEWER,
      activeViewerMock: {
        fileType: 'text',
        tooLarge: false,
        renderError: null,
        collapsed: false,
        type: 'simple',
      },
    };
  },
  computed: {
    isContentLoading() {
      return this.$apollo.queries.blobRaw.loading;
    },
    viewer() {
      const { richViewer, simpleViewer } = this.blob;
      return this.activeViewerType === RICH_BLOB_VIEWER ? richViewer : simpleViewer;
    },
    hasRenderError() {
      return Boolean(this.viewer.renderError);
    },
  },
  mounted() {
    document
      .querySelectorAll('.container-fluid.container-limited.limit-container-width')
      .forEach((el) => {
        el.classList.remove('limit-container-width');
      });
  },
  methods: {
    switchViewer(newViewer) {
      this.activeViewerType = newViewer || SIMPLE_BLOB_VIEWER;
    },
    forceQuery() {
      this.$apollo.queries.blobContent.skip = false;
      this.$apollo.queries.blobContent.refetch();
    },
    onContentUpdate(data) {
      const { path: blobPath } = this.blob;
      const {
        blobs: { nodes: dataBlobs },
      } = data.snippets.nodes[0];
      const updatedBlobData = dataBlobs.find((blob) => blob.path === blobPath);
      return updatedBlobData.richData || updatedBlobData.plainData;
    },
  },
};
</script>

<template>
  <div class="blob-content-holder" id="blob-content-holder">
    <article class="file-holder snippet-file-content">
      <div class="js-file-title file-title-flex-parent">
        <div class="file-header-content">
          <svg class="s16" data-testid="doc-text-icon">
            <use
              xlink:href="/assets/icons-a53822592d2fb2cd30ac129d53a7440a8aa3ffcd0bd43075602941d95b629b76.svg#doc-text"
            ></use>
          </svg>
          <strong class="file-title-name gl-word-break-all" data-qa-selector="file_name_content">
            {{ path }}
          </strong>
          <button
            class="btn gl-button btn btn-default-tertiary btn-icon btn-sm"
            data-toggle="tooltip"
            data-placement="bottom"
            data-container="body"
            data-class="gl-button btn btn-default-tertiary btn-icon btn-sm"
            data-title="Copy file path"
            data-clipboard-text='{"text":"team.yml","gfm":"`team.yml`"}'
            type="button"
            title="Copy file path"
            aria-label="Copy file path"
          >
            <svg class="s16" data-testid="copy-to-clipboard-icon">
              <use
                xlink:href="/assets/icons-a53822592d2fb2cd30ac129d53a7440a8aa3ffcd0bd43075602941d95b629b76.svg#copy-to-clipboard"
              ></use>
            </svg>
          </button>
          <small class="mr-1"> 1.02 MB </small>
        </div>

        <div
          class="file-actions gl-display-flex gl-align-items-center gl-flex-wrap gl-md-justify-content-end"
        >
          <a
            class="btn gl-button btn-confirm js-edit-blob gl-ml-3"
            data-track-event="click_edit"
            data-track-label="Edit"
            href="/flightjs/Flight/-/edit/master/team.yml"
            >Edit</a
          ><a
            class="btn gl-button btn-confirm ide-edit-button gl-ml-3 btn-inverted"
            data-track-event="click_edit_ide"
            data-track-label="Web IDE"
            data-track-property="secondary"
            href="/-/ide/project/flightjs/Flight/edit/master/-/team.yml"
            >Web IDE</a
          >
          <div class="btn-group gl-ml-3" role="group">
            <button
              name="button"
              type="submit"
              class="btn gl-button btn-default btn-default"
              data-target="#modal-upload-blob"
              data-toggle="modal"
            >
              Replace
            </button>
            <button
              name="button"
              type="submit"
              class="btn gl-button btn-default btn-default"
              data-target="#modal-remove-blob"
              data-toggle="modal"
            >
              Delete
            </button>
          </div>
          <div class="btn-group gl-ml-3" role="group">
            <button
              class="btn gl-button btn-default btn-icon js-copy-blob-source-btn"
              data-toggle="tooltip"
              data-placement="bottom"
              data-container="body"
              data-class="btn gl-button btn-default btn-icon js-copy-blob-source-btn"
              data-title="Copy file contents"
              data-clipboard-target=".blob-content[data-blob-id='de0eef1b44bfad6def32016460829e644c4ae409'] > pre"
              type="button"
              title="Copy file contents"
              aria-label="Copy file contents"
            >
              <svg class="s16" data-testid="copy-to-clipboard-icon">
                <use
                  xlink:href="/assets/icons-a53822592d2fb2cd30ac129d53a7440a8aa3ffcd0bd43075602941d95b629b76.svg#copy-to-clipboard"
                ></use>
              </svg>
            </button>
            <a
              class="btn gl-button btn-default btn-icon has-tooltip"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Open raw"
              title="Open raw"
              data-container="body"
              href="/flightjs/Flight/-/raw/master/team.yml"
              ><svg class="s16" data-testid="doc-code-icon">
                <use
                  xlink:href="/assets/icons-a53822592d2fb2cd30ac129d53a7440a8aa3ffcd0bd43075602941d95b629b76.svg#doc-code"
                ></use></svg
            ></a>
            <a
              download="team.yml"
              class="btn gl-button btn-default btn-icon has-tooltip"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Download"
              title="Download"
              data-container="body"
              href="/flightjs/Flight/-/raw/master/team.yml?inline=false"
              ><svg class="s16" data-testid="download-icon">
                <use
                  xlink:href="/assets/icons-a53822592d2fb2cd30ac129d53a7440a8aa3ffcd0bd43075602941d95b629b76.svg#download"
                ></use></svg
            ></a>
          </div>
        </div>
      </div>
      <blob-content
        v-if="blobRaw && blobInfo"
        :loading="isContentLoading"
        :content="blobRaw.raw"
        :blob="blobInfo"
        :active-viewer="activeViewerMock"
        :path="path"
      />
    </article>
  </div>
</template>
