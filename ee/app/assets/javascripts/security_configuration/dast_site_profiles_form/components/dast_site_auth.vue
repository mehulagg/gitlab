<script>
import { GlFormGroup, GlFormInput, GlToggle } from '@gitlab/ui';

const initField = value => ({
  value,
  state: null,
  feedback: null,
});

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlToggle,
  },
  data() {
    const form = {
      authenticationUrl: initField(),
      authenticationPassword: initField(),
    };

    return {
      form,
      isAuthEnabled: false,
    };
  },
  watch: {
    isFormValid: { handler: 'emitUpdate', immediate: true },
  },
  computed: {
    isFormValid() {
      return !this.isAuthEnabled || Object.values(this.form).every(({ state }) => state);
    },
  },
  methods: {
    emitUpdate() {
      this.$emit('update', {
        form: this.form,
        isValid: this.isFormValid,
      });
    },
    validate(fieldName, { target }) {
      const isFieldValid = target.checkValidity();
      this.form[fieldName].state = isFieldValid;
      this.form[fieldName].feedback = target.validationMessage;
    },
  },
};
</script>

<template>
  <section>
    <gl-form-group :label="s__('DastProfiles|Authentication')">
      <gl-toggle v-model="isAuthEnabled" />
    </gl-form-group>
    <div v-if="isAuthEnabled">
      <gl-form-group
        :label="s__('DastProfiles|Authentication URL')"
        :invalid-feedback="form.authenticationUrl.feedback"
      >
        <gl-form-input
          v-model="form.authenticationUrl.value"
          type="url"
          required
          :state="form.authenticationUrl.state"
          @blur="validate('authenticationUrl', $event)"
        />
      </gl-form-group>
      <gl-form-group
        :label="s__('DastProfiles|Authentication Password')"
        :invalid-feedback="form.authenticationPassword.feedback"
      >
        <gl-form-input
          v-model="form.authenticationPassword.value"
          type="text"
          required
          :state="form.authenticationPassword.state"
          @blur="validate('authenticationPassword', $event)"
        />
      </gl-form-group>
    </div>
  </section>
</template>
