<script>
import { GlFormGroup, GlFormTextarea, GlFormInput, GlToggle } from '@gitlab/ui';
import validation from '~/vue_shared/directives/validation';

const initField = value => ({
  value,
  state: null,
  feedback: null,
});

export default {
  components: {
    GlFormGroup,
    GlFormTextarea,
    GlFormInput,
    GlToggle,
  },
  directives: {
    validation,
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
      authenticationUrl: initField(),
      userName: initField(),
      password: initField(),
      userNameFormField: initField(),
      passwordFormField: initField(),
      excludedURLs: initField(),
      additionalRequestHeaders: initField(),
    };

    return {
      form,
      // @TODO: change to be "false"
      isAuthEnabled: true,
    };
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
  <form>
    <gl-form-group :label="s__('DastProfiles|Authentication')">
      <gl-toggle v-model="isAuthEnabled" />
    </gl-form-group>
    <div v-if="isAuthEnabled">
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Authentication URL')"
          :invalid-feedback="form.authenticationUrl.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.authenticationUrl.value"
            v-validation.blur="{ showValidation }"
            name="authenticationUrl"
            type="url"
            required
            :state="form.authenticationUrl.state"
          />
        </gl-form-group>
      </div>
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|User Name')"
          :invalid-feedback="form.userName.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.userName.value"
            v-validation.blur="{ showValidation }"
            autocomplete="off"
            name="userName"
            type="text"
            required
            :state="form.userName.state"
          />
        </gl-form-group>
        <gl-form-group
          :label="s__('DastProfiles|Password')"
          :invalid-feedback="form.password.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.password.value"
            v-validation.blur="{ showValidation }"
            autocomplete="off"
            name="password"
            type="password"
            required
            :state="form.password.state"
          />
        </gl-form-group>
      </div>
      <div class="row">
        <gl-form-group
          :label="s__('DastProfiles|Username form field')"
          :invalid-feedback="form.userNameFormField.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.userNameFormField.value"
            v-validation.blur="{ showValidation }"
            name="userNameFormField"
            type="text"
            required
            :state="form.userNameFormField.state"
          />
        </gl-form-group>
        <gl-form-group
          :label="s__('DastProfiles|Password form field')"
          :invalid-feedback="form.passwordFormField.feedback"
          class="col-md-6"
        >
          <gl-form-input
            v-model="form.passwordFormField.value"
            v-validation.blur="{ showValidation }"
            name="passwordFormField"
            type="password"
            required
            :state="form.passwordFormField.state"
          />
        </gl-form-group>
      </div>
      <div class="row">
        <gl-form-group :label="s__('DastProfiles|Excluded URLs (Optional)')" class="col-md-6">
          <gl-form-textarea v-model="form.excludedURLs.value" />
        </gl-form-group>
        <gl-form-group
          :label="s__('DastProfiles|Additional request headers (Optional)')"
          class="col-md-6"
        >
          <gl-form-textarea v-model="form.additionalRequestHeaders.value" />
        </gl-form-group>
      </div>
    </div>
  </form>
</template>
