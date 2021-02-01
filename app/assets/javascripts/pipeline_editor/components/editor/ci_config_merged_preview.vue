<script>
import { uniqueId } from 'lodash';
import { GlAlert } from '@gitlab/ui';
import { s__ } from '~/locale';
import EditorLite from '~/vue_shared/components/editor_lite.vue';

export default {
  i18n: {
    viewOnlyMessage: s__('Pipelines|This tab is read only'),
  },
  components: {
    EditorLite,
    GlAlert,
  },
  inject: ['ciConfigPath'],
  computed: {
    fileGlobalId() {
      return `${this.ciConfigPath}-${uniqueId()}`;
    },
  },
};
</script>
<template>
  <div>
    <gl-alert variant="info" class="gl-mb-3" :dismissible="false">
      {{ $options.i18n.viewOnlyMessage }}
    </gl-alert>
    <div class="gl-border-solid gl-border-gray-100 gl-border-1">
      <editor-lite
        ref="editor"
        :file-name="ciConfigPath"
        :file-global-id="fileGlobalId"
        :editor-options="{ readOnly: true }"
        v-bind="$attrs"
        v-on="$listeners"
      />
    </div>
  </div>
</template>
