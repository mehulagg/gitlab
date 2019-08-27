<script>
import { __, s__ } from '~/locale';
import _ from 'lodash-es';
import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { alertsValidator, queriesValidator } from '../validators';
import {
  GlButton,
  GlButtonGroup,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlModal,
  GlTooltipDirective,
} from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

Vue.use(Translate);

const SUBMIT_ACTION_TEXT = {
  create: __('Add'),
  update: __('Save'),
  delete: __('Delete'),
};

const SUBMIT_BUTTON_CLASS = {
  create: 'btn-success',
  update: 'btn-success',
  delete: 'btn-remove',
};

const OPERATORS = {
  greaterThan: '>',
  equalTo: '=',
  lessThan: '<',
};

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlModal,
    Icon,
  },
  directives: {
    GlTooltipDirective,
  },
  props: {
    disabled: {
      type: Boolean,
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    alertsToManage: {
      type: Object,
      required: false,
      default: () => ({}),
      validator: alertsValidator,
    },
    relevantQueries: {
      type: Array,
      required: true,
      validator: queriesValidator,
    },
    modalId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      operators: OPERATORS,
      operator: null,
      threshold: null,
      prometheusMetricId: null,
      selectedAlert: {},
      alertQuery: '',
    };
  },
  computed: {
    isValidQuery() {
      // TODO: Add query validation check (most likely via http request)
      return this.alertQuery.length ? true : null;
    },
    currentQuery() {
      return this.relevantQueries.find(query => query.metricId === this.prometheusMetricId) || {};
    },
    formDisabled() {
      // We need a prometheusMetricId to determine whether we're
      // creating/updating/deleting
      return this.disabled || !(this.prometheusMetricId || this.isValidQuery);
    },
    supportsComputedAlerts() {
      return gon.features && gon.features.prometheusComputedAlerts;
    },
    queryDropdownLabel() {
      return this.currentQuery.label || s__('PrometheusAlerts|Select query');
    },
    haveValuesChanged() {
      return (
        this.operator &&
        this.threshold === Number(this.threshold) &&
        (this.operator !== this.selectedAlert.operator ||
          this.threshold !== this.selectedAlert.threshold)
      );
    },
    submitAction() {
      if (_.isEmpty(this.selectedAlert)) return 'create';
      if (this.haveValuesChanged) return 'update';
      return 'delete';
    },
    submitActionText() {
      return SUBMIT_ACTION_TEXT[this.submitAction];
    },
    submitButtonClass() {
      return SUBMIT_BUTTON_CLASS[this.submitAction];
    },
    isSubmitDisabled() {
      return this.disabled || (this.submitAction === 'create' && !this.haveValuesChanged);
    },
    dropdownTitle() {
      return this.submitAction === 'create'
        ? s__('PrometheusAlerts|Add alert')
        : s__('PrometheusAlerts|Edit alert');
    },
  },
  watch: {
    alertsToManage() {
      this.resetAlertData();
    },
    submitAction() {
      this.$emit('setAction', this.submitAction);
    },
  },
  methods: {
    selectQuery(queryId) {
      const existingAlertPath = _.findKey(this.alertsToManage, alert => alert.metricId === queryId);
      const existingAlert = this.alertsToManage[existingAlertPath];

      if (existingAlert) {
        this.selectedAlert = existingAlert;
        this.operator = existingAlert.operator;
        this.threshold = existingAlert.threshold;
      } else {
        this.selectedAlert = {};
        this.operator = null;
        this.threshold = null;
      }

      this.prometheusMetricId = queryId;
    },
    handleCancel() {
      this.resetAlertData();
      this.$emit('cancel');
    },
    handleSubmit() {
      this.$emit(this.submitAction, {
        alert: this.selectedAlert.alert_path,
        operator: this.operator,
        threshold: this.threshold,
        prometheus_metric_id: this.prometheusMetricId,
      });
    },
    resetAlertData() {
      this.operator = null;
      this.threshold = null;
      this.prometheusMetricId = null;
      this.selectedAlert = {};
    },
  },
  alertQueryText: {
    label: __('Query'),
    validFeedback: __('Query is valid'),
    invalidFeedback: __('Invalid query'),
    descriptionTooltip: __(
      'Example: Usage = single query. (Requested) / (Capacity) = multiple queries combined into a formula.',
    ),
  },
};
</script>

<template>
  <gl-modal
    ref="alertModal"
    :title="dropdownTitle"
    :modal-id="modalId"
    :ok-variant="submitAction === 'delete' ? 'danger' : 'success'"
    :ok-title="submitActionText"
    :ok-disabled="formDisabled"
    class="prometheus-alert-widget d-flex align-items-center"
    @ok="handleSubmit"
  >
    <span v-if="errorMessage" class="alert-error-message"> {{ errorMessage }} </span>
    <div class="alert-form">
      <gl-form-group
        v-if="supportsComputedAlerts"
        :label="$options.alertQueryText.label"
        :valid-feedback="$options.alertQueryText.validFeedback"
        :invalid-feedback="$options.alertQueryText.invalidFeedback"
        :state="isValidQuery"
      >
        <gl-form-input v-model.trim="alertQuery" :state="isValidQuery" />
        <template #description>
          <div class="d-flex align-items-center">
            {{ __('Single or combined queries') }}
            <icon
              v-gl-tooltip-directive="$options.alertQueryText.descriptionTooltip"
              name="question"
              class="prepend-left-4"
            />
          </div>
        </template>
      </gl-form-group>
      <gl-dropdown
        v-else
        :text="queryDropdownLabel"
        class="form-group"
        toggle-class="dropdown-menu-toggle"
      >
        <gl-dropdown-item
          v-for="query in relevantQueries"
          :key="query.metricId"
          @click="selectQuery(query.metricId)"
        >
          {{ query.label }}
        </gl-dropdown-item>
      </gl-dropdown>
      <gl-button-group class="mb-2" :label="s__('PrometheusAlerts|Operator')">
        <gl-button
          :class="{ active: operator === operators.greaterThan }"
          :disabled="formDisabled"
          type="button"
          @click="operator = operators.greaterThan"
        >
          {{ operators.greaterThan }}
        </gl-button>
        <gl-button
          :class="{ active: operator === operators.equalTo }"
          :disabled="formDisabled"
          type="button"
          @click="operator = operators.equalTo"
        >
          {{ operators.equalTo }}
        </gl-button>
        <gl-button
          :class="{ active: operator === operators.lessThan }"
          :disabled="formDisabled"
          type="button"
          @click="operator = operators.lessThan"
        >
          {{ operators.lessThan }}
        </gl-button>
      </gl-button-group>
      <gl-form-group :label="s__('PrometheusAlerts|Threshold')" label-for="alerts-threshold">
        <gl-form-input
          id="alerts-threshold"
          v-model.number="threshold"
          :disabled="formDisabled"
          type="number"
        />
      </gl-form-group>
    </div>
  </gl-modal>
</template>
