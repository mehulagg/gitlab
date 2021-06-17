<script>
import { removeUnnecessaryDashes } from 'ee/threat_monitoring/utils';
import { __ } from '~/locale';
import { EDITOR_MODES, EDITOR_MODE_YAML } from '../constants';
import PolicyEditorLayout from '../policy_editor_layout.vue';
import { DEFAULT_SCAN_EXECUTION_POLICY, fromYaml } from './lib';

export default {
  DEFAULT_EDITOR_MODE: EDITOR_MODE_YAML,
  EDITOR_MODES: [EDITOR_MODES[1]],
  i18n: {
    createMergeRequest: __('Create merge request'),
  },
  components: {
    PolicyEditorLayout,
  },
  inject: ['threatMonitoringPath', 'projectId'],
  props: {
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    const yamlEditorValue = this.existingPolicy
      ? removeUnnecessaryDashes(this.existingPolicy.manifest)
      : DEFAULT_SCAN_EXECUTION_POLICY;

    return {
      policy: fromYaml(yamlEditorValue),
      yamlEditorValue,
    };
  },
  computed: {
    isEditing() {
      return Boolean(this.existingPolicy);
    },
  },
  methods: {
    updateYaml(manifest) {
      this.yamlEditorValue = manifest;
    },
  },
};
</script>

<template>
  <policy-editor-layout
    :default-editor-mode="$options.DEFAULT_EDITOR_MODE"
    :editor-modes="$options.EDITOR_MODES"
    :is-editing="isEditing"
    :policy-name="policy.name"
    :yaml-editor-value="yamlEditorValue"
    @update-yaml="updateYaml"
  >
    <template #save-button-text>
      {{ $options.i18n.createMergeRequest }}
    </template>
  </policy-editor-layout>
</template>
