<script>
import { GlFormGroup, GlFormInput, GlFormSelect } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { s__ } from '~/locale';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
import Step from './step.vue';

export default {
  name: 'BillingAddress',
  components: {
    Step,
    GlFormGroup,
    GlFormInput,
    GlFormSelect
  },
  directives: {
    autofocusonshow,
  },
  props: {
    customer: {
      type: Object,
      required: false,
      default: () => {},
    },
    countryId: {
      type: String,
      required: false,
      default: '',
    },
    countries: {
      type: Array,
      required: true,
      default: () => [],
    },
    stateId: {
      type: String,
      required: false,
      default: '',
    },
    states: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      selectedCountry: { value: this.countryId, name: null },
      selectedState: { value: this.stateId, name: null },
      address1: this.customer.address1,
      address2: this.customer.address2,
      city: this.customer.city,
      state: this.customer.state,
      zipCode: this.customer.zipCode,
      company: this.customer.company,
    };
  },
  computed: {
    isValid() {
      return (
        !isEmpty(this.selectedCountry) &&
        !isEmpty(this.address1) &&
        !isEmpty(this.city) &&
        !isEmpty(this.zipCode)
      );
    },
    countryOptions() {
      return this.countries.map(country => ({ text: country.name, value: country.id }));
    },
    stateOptions() {
      return this.states.map(state => ({ text: state.name, value: state.id }));
    },
    countryOptionsWithDefault() {
      return [
        {
          text: this.$options.i18n.countrySelectPrompt,
          value: null,
        },
        ...this.countryOptions,
      ];
    },
    stateOptionsWithDefault() {
      return [
        {
          text: this.$options.i18n.stateSelectPrompt,
          value: null,
        },
        ...this.stateOptions,
      ];
    },
  },
  method: {
    countryChanged() {
      this.$emit('countryChanged', this.country);
    }
  },
  i18n: {
    stepTitle: s__('Checkout|Billing address'),
    nextStepButtonText: s__('Checkout|Continue to payment'),
    countryLabel: s__('Checkout|Country'),
    countrySelectPrompt: s__('Checkout|Please select a country'),
    streetAddressLabel: s__('Checkout|Street address'),
    cityLabel: s__('Checkout|City'),
    stateLabel: s__('Checkout|State'),
    stateSelectPrompt: s__('Checkout|Please select a state'),
    zipCodeLabel: s__('Checkout|Zip code'),
  },
};
</script>
<template>
  <step
    step="billingAddress"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-form-group :label="$options.i18n.countryLabel" label-size="sm" class="mb-3">
        <gl-form-select
          v-model="selectedCountry"
          v-autofocusonshow
          :options="countryOptionsWithDefault"
          class="js-country"
          data-qa-selector="country"
          @change="countryChanged()"
        />
      </gl-form-group>
      <gl-form-group :label="$options.i18n.streetAddressLabel" label-size="sm" class="mb-3">
        <gl-form-input
          v-model="address1"
          type="text"
          data-qa-selector="street_address_1"
        />
        <gl-form-input
          v-model="address2"
          type="text"
          data-qa-selector="street_address_2"
        />
      </gl-form-group>
      <gl-form-group :label="$options.i18n.cityLabel" label-size="sm" class="mb-3">
        <gl-form-input v-model="city" type="text" data-qa-selector="city" />
      </gl-form-group>
      <div class="combined d-flex">
        <gl-form-group :label="$options.i18n.stateLabel" label-size="sm" class="mr-3 w-50">
          <gl-form-select
            v-model="selectedState"
            :options="stateOptionsWithDefault"
            data-qa-selector="state"
          />
        </gl-form-group>
        <gl-form-group :label="$options.i18n.zipCodeLabel" label-size="sm" class="w-50">
          <gl-form-input v-model="zipCode" type="text" data-qa-selector="zip_code" />
        </gl-form-group>
      </div>
    </template>
    <template #summary>
      <div class="js-summary-line-1">{{ address1 }}</div>
      <div class="js-summary-line-2">{{ adress2 }}</div>
      <div class="js-summary-line-3">{{ city }}, {{ countryState }} {{ zipCode }}</div>
    </template>
  </step>
</template>
