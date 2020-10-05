<script>
import $ from 'jquery';
import Vue from 'vue';
import { __ } from '~/locale';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import ActionsButton from '~/vue_shared/components/actions_button.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { joinPaths, webIDEUrl } from '~/lib/utils/url_utility';
import createRouter from '~/repository/router';

const KEY_EDIT = 'edit';
const KEY_WEB_IDE = 'webide';
const KEY_GITPOD = 'gitpod';

const WebIdeButton = {
  components: {
    ActionsButton,
    LocalStorageSync,
  },
  props: {
    webIdeUrl: {
      type: String,
      required: false,
      default: '',
    },
    editUrl: {
      type: String,
      required: false,
      default: '',
    },
    webIdeIsFork: {
      type: Boolean,
      required: false,
      default: false,
    },
    needsToFork: {
      type: Boolean,
      required: false,
      default: false,
    },
    showWebIdeButton: {
      type: Boolean,
      required: false,
      default: true,
    },
    showGitpodButton: {
      type: Boolean,
      required: false,
      default: false,
    },
    gitpodUrl: {
      type: String,
      required: false,
      default: '',
    },
    gitpodEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    isBlob: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      selection: KEY_WEB_IDE,
    };
  },
  computed: {
    actions() {
      return [this.editAction, this.webIdeAction, this.gitpodAction].filter(x => x);
    },
    editAction() {
      if (!this.isBlob) {
        return null;
      }

      return {
        key: KEY_EDIT,
        text: __('Edit'),
        secondaryText: __('Edit this file only.'),
        tooltip: '',
        href: this.editUrl,
      };
    },
    webIdeAction() {
      if (!this.showWebIdeButton) {
        return null;
      }

      const handleOptions = this.needsToFork
        ? { href: '#modal-confirm-fork', handle: () => this.showModal('#modal-confirm-fork') }
        : { href: this.webIdeUrl };

      let text = __('Web IDE');
      if (this.isBlob) text = __('Edit in Web IDE');
      if (this.webIdeIsFork) text = __('Edit fork in Web IDE');

      return {
        key: KEY_WEB_IDE,
        text,
        secondaryText: __('Quickly and easily edit multiple files in your project.'),
        tooltip: '',
        attrs: {
          'data-qa-selector': 'web_ide_button',
        },
        ...handleOptions,
      };
    },
    gitpodAction() {
      if (!this.showGitpodButton) {
        return null;
      }

      const handleOptions = this.gitpodEnabled
        ? { href: this.gitpodUrl }
        : { href: '#modal-enable-gitpod', handle: () => this.showModal('#modal-enable-gitpod') };

      const secondaryText = __('Launch a ready-to-code development environment for your project.');

      return {
        key: KEY_GITPOD,
        text: __('Gitpod'),
        secondaryText,
        tooltip: secondaryText,
        attrs: {
          'data-qa-selector': 'gitpod_button',
        },
        ...handleOptions,
      };
    },
  },
  methods: {
    select(key) {
      this.selection = key;
    },
    showModal(id) {
      $(id).modal('show');
    },
  },
};

export default WebIdeButton;

export function initWebIdeLink(webIdeLinkEl, isBlob = false) {
  if (!webIdeLinkEl) return;

  const {
    webIdeUrlData: { path: ideBasePath, isFork: webIdeIsFork },
    projectPath,
    escapedRef,
    ref,
    ...options
  } = convertObjectPropsToCamelCase(JSON.parse(webIdeLinkEl.dataset.options), { deep: true });

  const router = createRouter(projectPath, escapedRef);

  // eslint-disable-next-line no-new
  new Vue({
    el: webIdeLinkEl,
    router,
    render(h) {
      return h(WebIdeButton, {
        props: {
          webIdeUrl: webIDEUrl(
            joinPaths('/', ideBasePath, 'edit', ref, '-', this.$route.params.path || '', '/'),
          ),
          webIdeIsFork,
          isBlob,
          ...options,
        },
      });
    },
  });
}
</script>

<template>
  <div class="d-inline-block gl-ml-3">
    <actions-button
      :actions="actions"
      :selected-key="selection"
      :variant="isBlob ? 'info' : 'default'"
      :category="isBlob ? 'primary' : 'tertiary'"
      @select="select"
    />
    <local-storage-sync
      storage-key="gl-web-ide-button-selected"
      :value="selection"
      @input="select"
    />
  </div>
</template>
