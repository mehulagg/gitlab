<script>
import { GlFormGroup, GlButton } from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';
import { convertToSnakeCase, dasherize } from '~/lib/utils/text_utility';
import StepHeader from './step_header.vue';
import StepSummary from './step_summary.vue';

export default {
  components: {
    GlFormGroup,
    GlButton,
    StepHeader,
    StepSummary,
  },
  props: {
    step: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    isValid: {
      type: Boolean,
      required: true,
    },
    nextStepButtonText: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    isActive() {
      return this.currentStep === this.step;
    },
    isFinished() {
      return this.isValid && !this.isActive;
    },
    isEditable() {
      return this.isFinished && this.stepIndex(this.step) < this.currentStepIndex;
    },
    snakeCasedStep() {
      return dasherize(convertToSnakeCase(this.step));
    },
    ...mapGetters(['currentStep', 'stepIndex', 'currentStepIndex']),
  },
  methods: {
    ...mapActions(['activateStep', 'activateNextStep']),
    nextStep() {
      if (this.isValid) {
        this.activateNextStep();
      }
    },
    edit() {
      this.activateStep(this.step);
    },
  },
};
</script>
<template>
  <div class="mb-3 mb-lg-5">
    <step-header :title="title" :is-finished="isFinished" />
    <div :class="['card', snakeCasedStep]">
      <div v-show="isActive" @keyup.enter="nextStep">
        <slot name="body" :active="isActive"></slot>
        <gl-form-group v-if="nextStepButtonText" class="gl-mt-3 gl-mb-0">
          <gl-button variant="success" category="primary" :disabled="!isValid" @click="nextStep">
            {{ nextStepButtonText }}
          </gl-button>
        </gl-form-group>
      </div>
      <step-summary v-if="isFinished" :is-editable="isEditable" :edit="edit">
        <slot name="summary"></slot>
      </step-summary>
    </div>
  </div>
</template>
