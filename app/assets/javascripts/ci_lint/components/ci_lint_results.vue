<script>
import { GlAlert, GlTable } from '@gitlab/ui';
import CILintWarnings from './ci_lint_warnings.vue';
import { __ } from '~/locale';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

const thBorderColor = 'gl-border-gray-100!';

export default {
  correct: { variant: 'success', text: __('syntax is correct') },
  incorrect: { variant: 'danger', text: __('syntax is incorrect') },
  warningTitle: __('The form contains the following warning:'),
  fields: [
    {
      key: 'parameter',
      label: __('Parameter'),
      thClass: thBorderColor,
    },
    {
      key: 'value',
      label: __('Value'),
      thClass: thBorderColor,
    },
  ],
  components: {
    GlAlert,
    GlTable,
    'ci-lint-warnings': CILintWarnings,
  },
  props: {
    valid: {
      type: Boolean,
      required: true,
    },
    jobs: {
      type: Array,
      required: true,
    },
    errors: {
      type: Array,
      required: true,
    },
    warnings: {
      type: Array,
      required: true,
    },
    dryRun: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      isWarningDismissed: false,
    };
  },
  computed: {
    status() {
      return this.valid ? this.$options.correct : this.$options.incorrect;
    },
    shouldShowTable() {
      return this.errors.length === 0;
    },
    shouldShowError() {
      return this.errors.length > 0;
    },
    shouldShowWarning() {
      return this.warnings.length > 0 && !this.isWarningDismissed;
    },
  },
  methods: {
    formatParameterValue({ stage, name }) {
      return __(`${capitalizeFirstCharacter(stage)} Job - ${name}`);
    },
    formatRefs(obj) {
      // The refs property doesn't always exist, the object can be null
      return obj ? obj.refs.join(', ') : obj;
    },
    shouldShowScript(scriptArr) {
      return scriptArr.length > 0;
    },
    formatScript(scriptArr) {
      return scriptArr.join('\n');
    },
  },
};
</script>

<template>
  <div class="col-sm-12 gl-mt-5">
    <gl-alert
      class="gl-mb-5"
      :variant="status.variant"
      :title="__('Status:')"
      :dismissible="false"
      data-testid="ci-lint-status"
      >{{ status.text }}</gl-alert
    >

    <pre v-if="shouldShowError" class="gl-mb-5" data-testid="ci-lint-errors">{{
      errors.join('\n')
    }}</pre>

    <ci-lint-warnings
      v-if="shouldShowWarning"
      :warnings="warnings"
      data-testid="ci-lint-warnings"
      @dismiss="isWarningDismissed = true"
    />

    <gl-table
      v-if="shouldShowTable"
      :items="jobs"
      :fields="$options.fields"
      bordered
      data-testid="ci-lint-table"
    >
      <template #cell(parameter)="{ item }">
        <span data-testid="ci-lint-job-name"> {{ formatParameterValue(item) }} </span>
      </template>
      <template #cell(value)="{ item }">
        <pre v-if="shouldShowScript(item.before_script)" data-testid="ci-lint-before-script">{{
          formatScript(item.before_script)
        }}</pre>
        <pre>{{ formatScript(item.script) }}</pre>
        <pre v-if="shouldShowScript(item.after_script)" data-testid="ci-lint-after-script">{{
          formatScript(item.after_script)
        }}</pre>

        <ul class="gl-list-style-none gl-pl-0 gl-mb-0">
          <li>
            <b>{{ __('Tag list:') }}</b>
            {{ item.tag_list.join(', ') }}
          </li>
          <div v-if="!dryRun" data-testid="ci-lint-only-except">
            <li>
              <b>{{ __('Only policy:') }}</b>
              {{ formatRefs(item.only) }}
            </li>
            <li>
              <b>{{ __('Except policy:') }}</b>
              {{ formatRefs(item.except) }}
            </li>
          </div>
          <li>
            <b>{{ __('Environment:') }}</b>
            {{ item.environment }}
          </li>
          <li>
            <b>{{ __('When:') }}</b>
            {{ item.when }}
            <b v-if="item.allow_failure">{{ __('Allowed to fail') }}</b>
          </li>
        </ul>
      </template>
    </gl-table>
  </div>
</template>
