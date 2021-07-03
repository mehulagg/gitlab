<script>
import { GlModal, GlSprintf, GlLink } from '@gitlab/ui';
import Clipboard from 'clipboard';
import { getBaseURL, setUrlParams, redirectTo } from '~/lib/utils/url_utility';
import { sprintf, s__, __ } from '~/locale';
import { CODE_SNIPPET_SOURCE_URL_PARAM } from '~/pipeline_editor/components/code_snippet_alert/constants';
import { CONFIGURATION_SNIPPET_MODAL_ID } from './constants';

export default {
  CONFIGURATION_SNIPPET_MODAL_ID,
  components: {
    GlModal,
    GlSprintf,
    GlLink,
  },
  i18n: {
    helpText: s__(
      'This code snippet contains everything reflected in the configuration form. Copy and paste it into %{linkStart}.gitlab-ci.yml%{linkEnd} file and save your changes. Future %{scanType} scans will use these settings.',
    ),
    modalTitle: s__('SecurityConfiguration|%{scanType} configuration code snippet'),
    primaryText: s__('SecurityConfiguration|Copy code and open .gitlab-ci.yml file'),
    secondaryText: s__('SecurityConfiguration|Copy code only'),
    cancelText: __('Cancel'),
  },
  props: {
    ciYamlEditUrl: {
      type: String,
      required: true,
    },
    yaml: {
      type: String,
      required: true,
    },
    redirectParam: {
      type: String,
      required: true,
    },
    scanType: {
      type: String,
      required: true,
    },
  },
  computed: {
    modalTitle() {
      return sprintf(this.$options.i18n.modalTitle, {
        scanType: this.scanType,
      });
    },
  },
  methods: {
    show() {
      this.$refs.modal.show();
    },
    onHide() {
      this.clipboard?.destroy();
    },
    copySnippet(andRedirect = true) {
      const id = andRedirect ? 'copy-yaml-snippet-and-edit-button' : 'copy-yaml-snippet-button';
      const clipboard = new Clipboard(`#${id}`, {
        text: () => this.yaml,
      });
      clipboard.on('success', () => {
        if (andRedirect) {
          const url = new URL(this.ciYamlEditUrl, getBaseURL());
          redirectTo(
            setUrlParams(
              {
                [CODE_SNIPPET_SOURCE_URL_PARAM]: this.redirectParam,
              },
              url,
            ),
          );
        }
      });
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    :action-primary="{
      text: $options.i18n.primaryText,
      attributes: [{ variant: 'confirm' }, { id: 'copy-yaml-snippet-and-edit-button' }],
    }"
    :action-secondary="{
      text: $options.i18n.secondaryText,
      attributes: [{ variant: 'default' }, { id: 'copy-yaml-snippet-button' }],
    }"
    :action-cancel="{
      text: $options.i18n.cancelText,
    }"
    :modal-id="$options.CONFIGURATION_SNIPPET_MODAL_ID"
    :title="modalTitle"
    @hide="onHide"
    @primary="copySnippet"
    @secondary="copySnippet(false)"
  >
    <p class="gl-text-gray-500" data-testid="configuration-modal-help-text">
      <gl-sprintf :message="$options.i18n.helpText">
        <template #link="{ content }">
          <gl-link :href="ciYamlEditUrl" target="_blank">
            {{ content }}
          </gl-link>
        </template>
        <template #scanType>
          {{ scanType }}
        </template>
      </gl-sprintf>
    </p>

    <pre><code data-testid="configuration-modal-yaml-snippet" v-text="yaml"></code></pre>
  </gl-modal>
</template>
