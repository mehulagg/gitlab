<script>
import { GlButton, GlCollapse, GlForm, GlFormGroup, GlFormSelect, GlFormInput } from '@gitlab/ui';
import { integrationTypes } from '../constants';

export default {
  components: {
    GlButton,
    GlCollapse,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
  },
  data() {
    return {
      selectedIntegration: integrationTypes[0].value,
      options: integrationTypes,
      formVisible: false,
      form: {
        name: '',
      },
    };
  },
  methods: {
    onIntegrationTypeSelect() {
      this.formVisible = true;
    },
    onSubmit() {
      // TODO Add GrapgQL method
    },
    onReset() {
      this.form.name = '';
    },
  },
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit" @reset.prevent="onReset">
    <gl-form-group
      id="integration-type"
      label="1. Select integration type"
      label-for="integration-type"
      description="Learn more."
    >
      <gl-form-select
        id="integration-type"
        v-model="selectedIntegration"
        :options="options"
        @change="onIntegrationTypeSelect"
      />
    </gl-form-group>
    <gl-collapse v-model="formVisible" class="gl-mt-3">
      <gl-form-group id="name-integration" label="2. Name integration" label-for="name-integration">
        <gl-form-input
          id="name-integration"
          v-model="form.name"
          type="text"
          :placeholder="__('Enter integration name')"
        />
      </gl-form-group>
      <div class="gl-display-flex gl-justify-content-end">
        <gl-button type="reset" class="gl-mr-3">{{ __('Cancel') }}</gl-button>
        <gl-button type="submit" category="secondary" variant="success">{{
          __('Save and test payload')
        }}</gl-button>
        <gl-button type="submit" variant="success">{{ __('Save integration') }}</gl-button>
      </div>
    </gl-collapse>
  </gl-form>
</template>
