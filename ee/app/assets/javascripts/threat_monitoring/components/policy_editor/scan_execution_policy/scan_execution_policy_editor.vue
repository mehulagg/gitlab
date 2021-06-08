<script>
import { GlFormGroup, GlSegmentedControl } from '@gitlab/ui';
import { EDITOR_MODES, EditorModeYAML } from '../constants';
import PolicyEditorFormActions from '../policy_editor_form_actions.vue';
import { DEFAULT_SCAN_EXECUTION_POLICY } from './lib';

export default {
  EDITOR_MODES: [EDITOR_MODES[1]],
  components: {
    GlFormGroup,
    GlSegmentedControl,
    PolicyYamlEditor: () =>
      import(/* webpackChunkName: 'policy_yaml_editor' */ '../../policy_yaml_editor.vue'),
    PolicyEditorFormActions,
  },
  inject: {
    threatMonitoringPath: {
      type: String,
      default: '',
    },
    projectId: {
      type: String,
      default: '',
    },
  },
  props: {
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    const policy = this.existingPolicy
      ? this.existingPolicy.manifest
      : DEFAULT_SCAN_EXECUTION_POLICY;

    const yamlEditorValue = this.existingPolicy
      ? this.existingPolicy.manifest
      : DEFAULT_SCAN_EXECUTION_POLICY;

    return {
      editorMode: EditorModeYAML,
      yamlEditorValue,
      yamlEditorError: policy.error ? true : null,
      policy,
    };
  },
};
</script>

<template>
  <section>
    <div class="gl-mb-5 gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base">
      <gl-form-group
        class="gl-px-5 gl-py-3 gl-mb-0 gl-bg-gray-10 gl-border-b-solid gl-border-b-gray-100 gl-border-b-1"
      >
        <gl-segmented-control
          data-testid="editor-mode"
          :options="$options.EDITOR_MODES"
          :checked="editorMode"
        />
      </gl-form-group>
      <div class="gl-display-flex gl-sm-flex-direction-column">
        <section class="gl-w-full gl-p-5 gl-flex-fill-4 policy-table-left">
          <policy-yaml-editor
            data-testid="policy-yaml-editor"
            :value="yamlEditorValue"
            :read-only="false"
            @input="loadYaml"
          />
        </section>
      </div>
    </div>
    <policy-editor-form-actions :should-show-merge-request-button="true" />
  </section>
</template>
