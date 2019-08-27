<script>
import { GlFormInput, GlButton, GlLink, GlFormGroup, GlFormRadioGroup } from '@gitlab/ui';
import { debounce } from 'lodash-es';
import axios from '~/lib/utils/axios_utils';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import csrf from '~/lib/utils/csrf';
import { queryTypes, formDataValidator } from '../constants';

export default {
  components: {
    GlFormInput,
    GlButton,
    GlLink,
    GlFormGroup,
    GlFormRadioGroup,
    Icon,
  },
  props: {
    formOperation: {
      type: String,
      required: true,
    },
    formData: {
      type: Object,
      required: false,
      default: () => ({
        title: '',
        yLabel: '',
        query: '',
        unit: '',
        group: '',
        legend: '',
      }),
      validator: formDataValidator,
    },
    metricPersisted: {
      type: Boolean,
      required: false,
      default: false,
    },
    validateQueryPath: {
      type: String,
      required: true,
    },
  },
  data() {
    const group = this.formData.group.length ? this.formData.group : queryTypes.business;

    return {
      queryIsValid: null,
      ...this.formData,
      group,
    };
  },
  computed: {
    formIsValid() {
      return Boolean(
        this.queryIsValid &&
          this.title.length &&
          this.yLabel.length &&
          this.unit.length &&
          this.group.length,
      );
    },
    validQueryMsg() {
      return this.queryIsValid ? s__('Metrics|PromQL query is valid') : '';
    },
    invalidQueryMsg() {
      return !this.queryIsValid ? this.errorMessage : '';
    },
  },
  watch: {
    formIsValid(value) {
      this.$emit('formValidation', value);
    },
  },
  beforeMount() {
    if (this.metricPersisted) {
      this.validateQuery();
    }
  },
  methods: {
    requestValidation() {
      return axios.post(this.validateQueryPath, {
        query: this.query,
      });
    },
    validateQuery() {
      this.requestValidation()
        .then(res => {
          const response = res.data;
          const { valid, error } = response.query;

          if (response.success) {
            this.errorMessage = valid ? '' : error;
            this.queryIsValid = valid;
          } else {
            throw new Error(__('There was an error trying to validate your query'));
          }
        })
        .catch(() => {
          this.errorMessage = s__('Metrics|There was an error trying to validate your query');
          this.queryIsValid = false;
        });
    },
    debouncedValidateQuery: debounce(function checkQuery() {
      this.validateQuery();
    }, 500),
  },
  csrfToken: csrf.token || '',
  formGroupOptions: [
    { text: __('Business'), value: queryTypes.business },
    { text: __('Response'), value: queryTypes.response },
    { text: __('System'), value: queryTypes.system },
  ],
};
</script>

<template>
  <div>
    <input ref="method" type="hidden" name="_method" :value="formOperation" />
    <input :value="$options.csrfToken" type="hidden" name="authenticity_token" />
    <gl-form-group :label="__('Name')" label-for="prometheus_metric_title" label-class="label-bold">
      <gl-form-input
        id="prometheus_metric_title"
        v-model="title"
        name="prometheus_metric[title]"
        class="form-control"
        :placeholder="s__('Metrics|e.g. Throughput')"
        required
      />
      <span class="form-text text-muted">{{ s__('Metrics|Used as a title for the chart') }}</span>
    </gl-form-group>
    <gl-form-group :label="__('Type')" label-for="prometheus_metric_group" label-class="label-bold">
      <gl-form-radio-group
        id="metric-group"
        v-model="group"
        :options="$options.formGroupOptions"
        :checked="group"
        name="prometheus_metric[group]"
      />
      <span class="form-text text-muted">{{ s__('Metrics|For grouping similar metrics') }}</span>
    </gl-form-group>
    <gl-form-group
      :label="__('Query')"
      label-for="prometheus_metric_query"
      label-class="label-bold"
      :state="queryIsValid"
    >
      <gl-form-input
        id="prometheus_metric_query"
        v-model="query"
        name="prometheus_metric[query]"
        class="form-control"
        :placeholder="s__('Metrics|e.g. rate(http_requests_total[5m])')"
        required
        :state="queryIsValid"
        @input="debouncedValidateQuery"
      />
      <slot name="valid-feedback">
        <span class="form-text cgreen">
          {{ validQueryMsg }}
        </span>
      </slot>
      <slot name="invalid-feedback">
        <span class="form-text cred">
          {{ invalidQueryMsg }}
        </span>
      </slot>
      <span v-show="query.length === 0" class="form-text text-muted">
        {{ s__('Metrics|Must be a valid PromQL query.') }}
        <gl-link href="https://prometheus.io/docs/prometheus/latest/querying/basics/" tabindex="-1">
          {{ s__('Metrics|Prometheus Query Documentation') }}
          <icon name="external-link" :size="12" />
        </gl-link>
      </span>
    </gl-form-group>
    <gl-form-group
      :label="s__('Metrics|Y-axis label')"
      label-for="prometheus_metric_y_label"
      label-class="label-bold"
    >
      <gl-form-input
        id="prometheus_metric_y_label"
        v-model="yLabel"
        name="prometheus_metric[y_label]"
        class="form-control"
        :placeholder="s__('Metrics|e.g. Requests/second')"
        required
      />
      <span class="form-text text-muted">
        {{
          s__('Metrics|Label of the y-axis (usually the unit). The x-axis always represents time.')
        }}
      </span>
    </gl-form-group>
    <gl-form-group
      :label="s__('Metrics|Unit label')"
      label-for="prometheus_metric_unit"
      label-class="label-bold"
    >
      <gl-form-input
        id="prometheus_metric_unit"
        v-model="unit"
        name="prometheus_metric[unit]"
        class="form-control"
        :placeholder="s__('Metrics|e.g. req/sec')"
        required
      />
    </gl-form-group>
    <gl-form-group
      :label="s__('Metrics|Legend label (optional)')"
      label-for="prometheus_metric_legend"
      label-class="label-bold"
    >
      <gl-form-input
        id="prometheus_metric_legend"
        v-model="legend"
        name="prometheus_metric[legend]"
        class="form-control"
        :placeholder="s__('Metrics|e.g. HTTP requests')"
        required
      />
      <span class="form-text text-muted">
        {{
          s__(
            'Metrics|Used if the query returns a single series. If it returns multiple series, their legend labels will be picked up from the response.',
          )
        }}
      </span>
    </gl-form-group>
  </div>
</template>
