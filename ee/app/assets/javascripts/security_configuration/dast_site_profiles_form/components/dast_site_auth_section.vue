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
    showValidation: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const form = {
      state: false,
      fields: {
        authenticationUrl: initField(),
        userName: initField(),
        password: initField(),
        userNameFormField: initField(),
        passwordFormField: initField(),
        excludedURLs: initField(),
        additionalRequestHeaders: initField(),
      },
    };

    return {
      form,
      isAuthEnabled: false,
    };
  },
  watch: {
    form: { handler: 'emitUpdate', immediate: true, deep: true },
  },
  methods: {
    emitUpdate() {
      const { form, isAuthEnabled } = this;
      this.$emit('input', { form, isAuthEnabled });
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
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Authentication URL')"
          :invalid-feedback="form.fields.authenticationUrl.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.fields.authenticationUrl.value"
            v-validation:[showValidation]
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
            v-validation:[showValidation]
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
            v-validation:[showValidation]
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
            v-validation:[showValidation]
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
            v-validation:[showValidation]
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
