<script>
import { GlFormGroup, GlFormInputGroup } from '@gitlab/ui';

export default {
  components: {
    GlFormGroup,
    GlFormInputGroup,
  },
  props: {
    value: {
      required: false,
      type: Object,
      default: null,
    },
  },
  computed: {
    isDotCom() {
      return gon?.dot_com || true;
    },
  },
  methods: {
    onInputPublicProjectMinutesCostFactor(val) {
      this.$emit('input', {
        ...this.value,
        publicProjectsMinutesCostFactor: val,
      });
    },
    onInputPrivateProjectMinutesCostFactor(val) {
      this.$emit('input', {
        ...this.value,
        privateProjectsMinutesCostFactor: val,
      });
    },
  },
};
</script>
<template>
  <div v-if="value">
    <pre>{{ value }}</pre>
    <gl-form-group
      data-testid="runner-field-public-projects-cost-factor"
      :label="__('Public projects Minutes cost factor')"
    >
      <gl-form-input-group
        :value="value.publicProjectsMinutesCostFactor"
        type="number"
        @input="onInputPublicProjectMinutesCostFactor"
      />
    </gl-form-group>

    <gl-form-group
      data-testid="runner-field-public-projects-cost-factor"
      :label="__('Private projects Minutes cost factor')"
    >
      <gl-form-input-group
        :value="value.privateProjectsMinutesCostFactor"
        type="number"
        @input="onInputPrivateProjectMinutesCostFactor"
      />
    </gl-form-group>
  </div>
</template>
