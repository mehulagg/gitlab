import Vue from 'vue';
import { mapActions, mapState, mapGetters } from 'vuex';
import Cookies from 'js-cookie';

import { parseBoolean, historyPushState } from '~/lib/utils/common_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';

import FindFile from '~/vue_shared/components/file_finder/index.vue';
import notesEventHub from '../notes/event_hub';
import { setFileByFile } from './store/actions';
import diffsApp from './components/app.vue';
import {
  TREE_LIST_STORAGE_KEY,
  DIFF_WHITESPACE_COOKIE_NAME,
  DIFF_FILE_BY_FILE_COOKIE_NAME,
  SINGLE_FILE_MODE,
  ALL_FILE_MODE,
  TOGGLE_FILE_BY_FILE_EVENT,
} from './constants';
import eventHub from "./event_hub";

export default function initDiffsApp(store) {
  const fileFinderEl = document.getElementById('js-diff-file-finder');

  if (fileFinderEl) {
    // eslint-disable-next-line no-new
    new Vue({
      el: fileFinderEl,
      store,
      computed: {
        ...mapState('diffs', ['fileFinderVisible', 'isLoading']),
        ...mapGetters('diffs', ['flatBlobsList']),
      },
      watch: {
        fileFinderVisible(newVal, oldVal) {
          if (newVal && !oldVal && !this.flatBlobsList.length) {
            notesEventHub.$emit('fetchDiffData');
          }
        },
      },
      methods: {
        ...mapActions('diffs', ['toggleFileFinder', 'scrollToFile']),
        openFile(file) {
          window.mrTabs.tabShown('diffs');
          this.scrollToFile(file.path);
        },
      },
      render(createElement) {
        return createElement(FindFile, {
          props: {
            files: this.flatBlobsList,
            visible: this.fileFinderVisible,
            loading: this.isLoading,
            showDiffStats: true,
            clearSearchOnClose: false,
          },
          on: {
            toggle: this.toggleFileFinder,
            click: this.openFile,
          },
          class: ['diff-file-finder'],
          style: {
            display: this.fileFinderVisible ? '' : 'none',
          },
        });
      },
    });
  }

  return new Vue({
    el: '#js-diffs-app',
    name: 'MergeRequestDiffs',
    components: {
      diffsApp,
    },
    store,
    data() {
      const { dataset } = document.querySelector(this.$options.el);

      return {
        endpoint: dataset.endpoint,
        endpointMetadata: dataset.endpointMetadata || '',
        endpointBatch: dataset.endpointBatch || '',
        endpointCoverage: dataset.endpointCoverage || '',
        projectPath: dataset.projectPath,
        helpPagePath: dataset.helpPagePath,
        currentUser: JSON.parse(dataset.currentUserData) || {},
        changesEmptyStateIllustration: dataset.changesEmptyStateIllustration,
        isFluidLayout: parseBoolean(dataset.isFluidLayout),
        dismissEndpoint: dataset.dismissEndpoint,
        showSuggestPopover: parseBoolean(dataset.showSuggestPopover),
        showWhitespaceDefault: parseBoolean(dataset.showWhitespaceDefault),
        viewDiffsFileByFile: parseBoolean(dataset.fileByFileDefault),
      };
    },
    computed: {
      ...mapState({
        activeTab: state => state.page.activeTab,
        fileByFile: state => state.diffs.viewDiffsFileByFile
      }),
    },
    created() {
      const treeListStored = localStorage.getItem(TREE_LIST_STORAGE_KEY);
      const renderTreeList = treeListStored !== null ? parseBoolean(treeListStored) : true;

      this.setRenderTreeList(renderTreeList);
      this.updateFileByFile( this.viewDiffsFileByFile );

      // Set whitespace default as per user preferences unless cookie is already set
      if (!Cookies.get(DIFF_WHITESPACE_COOKIE_NAME)) {
        const hideWhitespace = this.showWhitespaceDefault ? '0' : '1';
        this.setShowWhitespace({ showWhitespace: hideWhitespace !== '1' });
      }

      eventHub.$on(TOGGLE_FILE_BY_FILE_EVENT, (event) => {
        let fileByFile = !this.fileByFile;

        if( Object.prototype.hasOwnProperty.call( event, 'force' ) ){
          fileByFile = Boolean( event.force );
        }

        this.updateFileByFile( fileByFile, { updateUrl: true } );
      });
    },
    methods: {
      ...mapActions('diffs', ['setRenderTreeList', 'setShowWhitespace', 'setFileByFile']),
      updateFileByFile( newFileByFileSetting, { updateUrl = false } ){
        let setting = newFileByFileSetting;

        if( typeof setting !== 'boolean' ){
          setting = setting === SINGLE_FILE_MODE;
        }

        const fbf = setting ? SINGLE_FILE_MODE : ALL_FILE_MODE;

        setFileByFile({ fileByFile: setting });
        Cookies.set(DIFF_FILE_BY_FILE_COOKIE_NAME, fbf );

        if (updateUrl) {
          historyPushState(mergeUrlParams({ singleFile: fbf }, window.location.href));
        }
      }
    },
    render(createElement) {
      return createElement('diffs-app', {
        props: {
          endpoint: this.endpoint,
          endpointMetadata: this.endpointMetadata,
          endpointBatch: this.endpointBatch,
          endpointCoverage: this.endpointCoverage,
          currentUser: this.currentUser,
          projectPath: this.projectPath,
          helpPagePath: this.helpPagePath,
          shouldShow: this.activeTab === 'diffs',
          changesEmptyStateIllustration: this.changesEmptyStateIllustration,
          isFluidLayout: this.isFluidLayout,
          dismissEndpoint: this.dismissEndpoint,
          showSuggestPopover: this.showSuggestPopover,
          viewDiffsFileByFile: this.viewDiffsFileByFile,
        },
      });
    },
  });
}
