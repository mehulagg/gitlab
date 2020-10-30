<script>
import { GlFormGroup, GlFormInput, GlToggle } from '@gitlab/ui';
import validation from '~/vue_shared/directives/validation';

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
  directives: {
    validation: validation(),
  },
  props: {
    authEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
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
      authenticationUrl,
      userName,
      password,
      userNameFormField,
      passwordFormField,
    } = this.fields;

    return {
      form: {
        state: false,
        fields: {
          authenticationUrl: initField(authenticationUrl),
          userName: initField(userName),
          password: initField(password),
          userNameFormField: initField(userNameFormField),
          passwordFormField: initField(passwordFormField),
        },
      },
      isAuthEnabled: this.authEnabled,
    };
  },
  computed: {
    showValidationOrInEditMode() {
      return this.showValidation || Object.keys(this.fields).length > 0;
    },
    eventData() {
      const { form, isAuthEnabled } = this;
      return {
        form,
        isAuthEnabled,
      };
    },
  },
  watch: {
    isAuthEnabled: 'emitUpdate',
    form: { handler: 'emitUpdate', immediate: true, deep: true },
  },
  methods: {
    emitUpdate() {
      this.$emit('input', this.eventData);
    },
  },
};
</script>

<template>
  <section>
    <gl-form-group :label="s__('DastProfiles|Authentication')">
      <gl-toggle v-model="isAuthEnabled" data-testid="auth-toggle" />
    </gl-form-group>
    <div v-if="isAuthEnabled" data-testid="auth-form">
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
          :label="s__('DastProfiles|User Name')"
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
            type="password"
            required
            :state="form.fields.passwordFormField.state"
          />
        </gl-form-group>
      </div>
    </div>
  </section>
</template>
