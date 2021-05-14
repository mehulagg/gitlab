<script>
import { GlLink, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { cloneDeep } from 'lodash';
import createFlash from '~/flash';
import { s__, __ } from '~/locale';
import { defaultEscalationRule } from '../constants';
import getOncallSchedulesQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import EscalationRule from './escalation_rule.vue';

export const i18n = {
  fields: {
    name: {
      title: __('Name'),
      validation: {
        empty: __("Can't be empty"),
      },
    },
    description: { title: __('Description (optional)') },
    rules: {
      title: s__('EscalationPolicies|Escalation rules'),
      validation: {
        empty: __("Can't be empty"),
      },
      ifNot: s__('EscalationPolicies|IF alert is not'),
      in: __('in'),
      minutes: __('minutes'),
      then: __('THEN'),
    },
  },
  addRule: s__('EscalationPolicies|Add an additional rule'),
  failedLoadingSchedules: s__('EscalationPolicies|Failed to load oncall-schedules'),
};

export default {
  i18n,
  components: {
    GlLink,
    GlForm,
    GlFormGroup,
    GlFormInput,
    EscalationRule,
  },
  inject: ['projectPath'],
  props: {
    form: {
      type: Object,
      required: true,
    },
    validationState: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      schedules: [],
      rules: [cloneDeep(defaultEscalationRule)],
    };
  },
  apollo: {
    schedules: {
      query: getOncallSchedulesQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update(data) {
        const nodes = data.project?.incidentManagementOncallSchedules?.nodes ?? [];
        return nodes;
      },
      error(error) {
        createFlash({ message: i18n.failedLoadingSchedules, captureError: true, error });
      },
    },
  },
  computed: {},
  methods: {
    addRule() {
      this.rules.push(cloneDeep(defaultEscalationRule));
    },
    updateEscalationRules(index, rule) {
      this.rules[index] = rule;
      this.$emit('update-escalation-policy-form', { type: 'rules', value: this.rules });
    },
  },
};
</script>

<template>
  <gl-form>
    <div class="w-75 gl-xs-w-full!">
      <gl-form-group
        data-testid="escalation-policy-name"
        :label="$options.i18n.fields.name.title"
        :invalid-feedback="$options.i18n.fields.name.validation.empty"
        label-size="sm"
        label-for="escalation-policy-name"
        :state="validationState.name"
        requried
      >
        <gl-form-input
          id="escalation-policy-name"
          :value="form.name"
          @blur="
            $emit('update-escalation-policy-form', { type: 'name', value: $event.target.value })
          "
        />
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.description.title"
        label-size="sm"
        label-for="escalation-policy-description"
      >
        <gl-form-input
          id="escalation-policy-description"
          :value="form.description"
          @blur="
            $emit('update-escalation-policy-form', {
              type: 'description',
              value: $event.target.value,
            })
          "
        />
      </gl-form-group>
    </div>

    <gl-form-group
      class="escalation-policy-rules"
      :label="$options.i18n.fields.rules.title"
      label-size="sm"
      :state="validationState.rules"
    >
      <escalation-rule
        v-for="(rule, index) in rules"
        :key="index"
        :rule="rule"
        :index="index"
        :schedules="schedules"
        @update-escalation-rule="updateEscalationRules"
      />
    </gl-form-group>
    <gl-link @click="addRule">
      <span>+ {{ $options.i18n.addRule }}</span>
    </gl-link>
  </gl-form>
</template>
