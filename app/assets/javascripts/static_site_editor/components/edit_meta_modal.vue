<script>
import { GlModal } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import AccessorUtilities from '~/lib/utils/accessor';

import EditMetaControls from './edit_meta_controls.vue';

import { MR_META_LOCAL_STORAGE_KEY } from '../constants';

export default {
  components: {
    GlModal,
    EditMetaControls,
  },
  props: {
    sourcePath: {
      type: String,
      required: true,
    },
  },
  data() {
    let mergeRequestMeta = {
      title: sprintf(s__(`StaticSiteEditor|Update %{sourcePath} file`), {
        sourcePath: this.sourcePath,
      }),
      description: s__('StaticSiteEditor|Copy update'),
    };

    if (
      AccessorUtilities.isLocalStorageAccessSafe() &&
      localStorage.getItem(MR_META_LOCAL_STORAGE_KEY)
    ) {
      mergeRequestMeta = JSON.parse(localStorage.getItem(MR_META_LOCAL_STORAGE_KEY));
    }

    return {
      mergeRequestMeta,
    };
  },
  computed: {
    disabled() {
      return this.mergeRequestMeta.title === '';
    },
    primaryProps() {
      return {
        text: __('Submit changes'),
        attributes: [{ variant: 'success' }, { disabled: this.disabled }],
      };
    },
    secondaryProps() {
      return {
        text: __('Keep editing'),
        attributes: [{ variant: 'default' }],
      };
    },
  },
  methods: {
    hide() {
      this.$refs.modal.hide();
    },
    show() {
      this.$refs.modal.show();
    },
    onPrimary() {
      this.$emit('primary', this.mergeRequestMeta);

      if (AccessorUtilities.isLocalStorageAccessSafe()) {
        window.localStorage.removeItem(MR_META_LOCAL_STORAGE_KEY);
      }
    },
    onSecondary() {
      this.hide();
    },
    onUpdateSettings(mergeRequestMeta) {
      this.mergeRequestMeta = { ...mergeRequestMeta };

      if (AccessorUtilities.isLocalStorageAccessSafe()) {
        window.localStorage.setItem(MR_META_LOCAL_STORAGE_KEY, JSON.stringify(mergeRequestMeta));
      }
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    modal-id="edit-meta-modal"
    :title="__('Submit your changes')"
    :action-primary="primaryProps"
    :action-secondary="secondaryProps"
    size="sm"
    @primary="onPrimary"
    @secondary="onSecondary"
    @hide="() => $emit('hide')"
  >
    <edit-meta-controls
      ref="editMetaControls"
      :title="mergeRequestMeta.title"
      :description="mergeRequestMeta.description"
      @updateSettings="onUpdateSettings"
    />
  </gl-modal>
</template>
