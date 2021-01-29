<script>
import { GlLoadingIcon } from '@gitlab/ui';
import axios from '../../lib/utils/axios_utils';
import getRefMixin from '../mixins/get_ref';
import projectPathQuery from '../queries/project_path.query.graphql';
import blobQuery from '../queries/blob.query.graphql';

const LIMIT = 1000;
const PAGE_SIZE = 100;
export const INITIAL_FETCH_COUNT = LIMIT / PAGE_SIZE;

export default {
  components: { GlLoadingIcon },
  mixins: [getRefMixin],
  apollo: {
    projectPath: {
      query: projectPathQuery,
    },
    blob: {
      query: blobQuery,
      variables() {
        return {
          blobName: '.gitignore',
          projectPath: this.projectPath,
          ref: this.ref,
          path: '/', // this.$route.params.path.replace(/^\//, ''),
          pageSize: 100,
        };
      },
      context: {
        isSingleRequest: true,
      },
      error(error) {
        throw error;
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
      isLoadingFile: false,
      viewerHTML: '',
    };
  },
  computed: {
    hasShowMore() {
      return !this.clickedShowMore && this.fetchCounter === INITIAL_FETCH_COUNT;
    },
  },

  watch: {
    $route: function routeChange() {
      this.fetchFile();
    },
  },
  mounted() {
    // We need to wait for `ref` and `projectPath` to be set
    this.$nextTick(() => this.fetchFile());
  },
  methods: {
    fetchFile() {
      const originalPath = this.projectPath || '/';
      this.isLoadingFile = true;

      console.log('PATHS ' + this.path + ' - ' + this.projectPath);

      const loadUrl = `/flightjs/flight/-/blob/master/${this.path}?format=json&viewer=simple`;
      // const loadRawUrl = '/flightjs/flight/-/raw/master/lib/logger.js?format=json&viewer=simple';

      return axios.get(loadUrl).then(({ data }) => {
        console.log('Loaded Content Data : ', data);
        this.viewerHTML = data.html;
        this.isLoadingFile = false;
        /*
        viewer.innerHTML = data.html;
        viewer.setAttribute('data-loaded', 'true');

        eventHub.$emit('showBlobInteractionZones', viewer.dataset.path);

        return viewer;
        */
      });

      console.log('Fetching File ' + this.projectPath + '/' + this.path);
    },
  },
};
</script>

<template>
  <div class="blob-content-holder" id="blob-content-holder">
    <article class="file-holder">
      <div class="js-file-title file-title-flex-parent">
        <div class="file-header-content">
          <svg class="s16" data-testid="doc-text-icon">
            <use
              xlink:href="/assets/icons-2fb014ce49a3e87b1e47aae4b8adfa35e6b59f49e1474a18a2518ad2285bce08.svg#doc-text"
            ></use>
          </svg>
          <strong class="file-title-name gl-word-break-all" data-qa-selector="file_name_content">
            logger.js
          </strong>
          <button
            class="btn btn-clipboard btn-transparent"
            data-toggle="tooltip"
            data-placement="bottom"
            data-container="body"
            data-class="btn-clipboard btn-transparent"
            data-title="Copy file path"
            data-clipboard-text='{"text":"lib/logger.js","gfm":"`lib/logger.js`"}'
            type="button"
            title="Copy file path"
            aria-label="Copy file path"
          >
            <svg class="s16" data-testid="copy-to-clipboard-icon">
              <use
                xlink:href="/assets/icons-2fb014ce49a3e87b1e47aae4b8adfa35e6b59f49e1474a18a2518ad2285bce08.svg#copy-to-clipboard"
              ></use>
            </svg>
          </button>
          <small class="mr-1"> 3.1 KB </small>
        </div>

        <div
          class="file-actions gl-display-flex gl-flex-fill-1 gl-align-self-start gl-md-justify-content-end"
        >
          <a
            class="btn btn-primary js-edit-blob gl-mr-3 btn-sm"
            data-track-event="click_edit"
            data-track-label="Edit"
            href="/flightjs/flight/-/edit/master/lib/logger.js"
            >Edit</a
          ><a
            class="btn btn-primary ide-edit-button gl-mr-3 btn-inverted btn-sm"
            data-track-event="click_edit_ide"
            data-track-label="Web IDE"
            data-track-property="secondary"
            href="/-/ide/project/flightjs/flight/edit/master/-/lib/logger.js"
            >Web IDE</a
          >
          <div class="btn-group ml-2" role="group">
            <a
              class="btn btn-sm path-lock has-tooltip"
              data-state="lock"
              data-toggle="tooltip"
              title=""
              data-qa-selector="lock_button"
              href="#"
              >Lock</a
            >

            <button
              name="button"
              type="submit"
              class="btn btn-default"
              data-target="#modal-upload-blob"
              data-toggle="modal"
            >
              Replace
            </button>
            <button
              name="button"
              type="submit"
              class="btn btn-default"
              data-target="#modal-remove-blob"
              data-toggle="modal"
            >
              Delete
            </button>
          </div>
          <div class="btn-group ml-2" role="group">
            <button
              class="btn btn-sm js-copy-blob-source-btn"
              data-toggle="tooltip"
              data-placement="bottom"
              data-container="body"
              data-class="btn btn-sm js-copy-blob-source-btn"
              data-title="Copy file contents"
              data-clipboard-target=".blob-content[data-blob-id='4cac2fee32d8c3b0d6b5cbefec2eed4a7c978e34'] > pre"
              type="button"
              title=""
              aria-label="Copy file contents"
              data-original-title="Copy file contents"
            >
              <svg class="s16" data-testid="copy-to-clipboard-icon">
                <use
                  xlink:href="/assets/icons-2fb014ce49a3e87b1e47aae4b8adfa35e6b59f49e1474a18a2518ad2285bce08.svg#copy-to-clipboard"
                ></use>
              </svg>
            </button>
            <a
              class="btn btn-sm has-tooltip"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Open raw"
              title="Open raw"
              data-container="body"
              href="/flightjs/flight/-/raw/master/lib/logger.js"
              ><svg class="s16" data-testid="doc-code-icon">
                <use
                  xlink:href="/assets/icons-2fb014ce49a3e87b1e47aae4b8adfa35e6b59f49e1474a18a2518ad2285bce08.svg#doc-code"
                ></use></svg
            ></a>
            <a
              download="lib/logger.js"
              class="btn btn-sm has-tooltip"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Download"
              title="Download"
              data-container="body"
              href="/flightjs/flight/-/raw/master/lib/logger.js?inline=false"
              ><svg class="s16" data-testid="download-icon">
                <use
                  xlink:href="/assets/icons-2fb014ce49a3e87b1e47aae4b8adfa35e6b59f49e1474a18a2518ad2285bce08.svg#download"
                ></use></svg
            ></a>
          </div>
        </div>
      </div>
      <div class="js-file-fork-suggestion-section file-fork-suggestion hidden">
        <span class="file-fork-suggestion-note">
          You're not allowed to
          <span class="js-file-fork-suggestion-section-action"> edit </span>
          files in this project directly. Please fork this project, make your changes there, and
          submit a merge request.
        </span>
        <a
          class="js-fork-suggestion-button gl-button btn btn-grouped btn-inverted btn-success"
          rel="nofollow"
          data-method="post"
          href="/flightjs/flight/-/blob/master/lib/logger.js"
          >Fork</a
        >
        <button class="js-cancel-fork-suggestion-button gl-button btn btn-grouped" type="button">
          Cancel
        </button>
      </div>

      <div
        class="blob-viewer"
        data-path="lib/logger.js"
        data-type="simple"
        data-url="/flightjs/flight/-/blob/master/lib/logger.js?format=json&amp;viewer=simple"
        data-loading="true"
        data-loaded="true"
      >
        <div class="blob-viewer" data-path="lib/logger.js" data-type="simple">
          <div class="file-content code js-syntax-highlight white" id="blob-content">
            <gl-loading-icon v-if="isLoadingFile" size="md" color="dark" class="m-auto" />
            <div v-if="!isLoadingFile" v-html="viewerHTML"></div>
          </div>
        </div>
      </div>
    </article>
  </div>
</template>
