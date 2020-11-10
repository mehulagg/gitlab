<script>
import { GlFormGroup, GlFormInput, GlFormCheckbox } from '@gitlab/ui';
import { initFormField } from 'ee/security_configuration/utils';
import validation from '~/vue_shared/directives/validation';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlFormCheckbox,
  },
  directives: {
    validation: validation(),
  },
  props: {
    fields: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    showValidation: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const {
      authEnabled,
      authenticationUrl,
      userName,
      password,
      // default to commonly used names for `userName` and `password` fields in authentcation forms
      userNameFormField = 'username',
      passwordFormField = 'password',
    } = this.fields;

    return {
      form: {
        state: false,
        fields: {
          authEnabled: initFormField({ value: authEnabled, skipValidation: true }),
          authenticationUrl: initFormField({ value: authenticationUrl }),
          userName: initFormField({ value: userName }),
          password: initFormField({ value: password }),
          userNameFormField: initFormField({ value: userNameFormField }),
          passwordFormField: initFormField({ value: passwordFormField }),
        },
      },
    };
  },
  computed: {
    showValidationOrInEditMode() {
      return this.showValidation || Object.keys(this.fields).length > 0;
    },
  },
  watch: {
    form: { handler: 'emitUpdate', immediate: true, deep: true },
  },
  methods: {
    emitUpdate() {
      this.$emit('input', this.form);
    },
  },
};
</script>

<template>
  <section>
    <gl-form-group :label="s__('DastProfiles|Authentication')">
      <gl-form-checkbox v-model="form.fields.authEnabled.value">{{
        s__('DastProfiles|Enable Authentication')
      }}</gl-form-checkbox>
    </gl-form-group>
    <div v-if="form.fields.authEnabled.value" data-testid="auth-form">
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Authentication URL')"
          :invalid-feedback="form.fields.authenticationUrl.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.authenticationUrl.value"
            v-validation:[showValidationOrInEditMode]
            name="authenticationUrl"
            type="url"
            required
            :state="form.fields.authenticationUrl.state"
          />
        </gl-form-group>
      </div>
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Username')"
          :invalid-feedback="form.fields.userName.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.userName.value"
            v-validation:[showValidationOrInEditMode]
            autocomplete="off"
            name="userName"
            type="text"
            required
            :state="form.fields.userName.state"
          />
        </gl-form-group>
        <gl-form-group
          :label="s__('DastProfiles|Password')"
          :invalid-feedback="form.fields.password.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.password.value"
            v-validation:[showValidationOrInEditMode]
            autocomplete="off"
            name="password"
            type="password"
            required
            :state="form.fields.password.state"
          />
        </gl-form-group>
      </div>
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Username form field')"
          :invalid-feedback="form.fields.userNameFormField.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.userNameFormField.value"
            v-validation:[showValidationOrInEditMode]
            name="userNameFormField"
            type="text"
            required
            :state="form.fields.userNameFormField.state"
          />
        </gl-form-group>
        <gl-form-group
          :label="s__('DastProfiles|Password form field')"
          :invalid-feedback="form.fields.passwordFormField.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.passwordFormField.value"
            v-validation:[showValidationOrInEditMode]
            name="passwordFormField"
            type="text"
            required
            :state="form.fields.passwordFormField.state"
          />
        </gl-form-group>
      </div>
    </div>
  </section>
</template>
