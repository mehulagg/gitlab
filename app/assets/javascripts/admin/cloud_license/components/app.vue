<script>
import { GlButton, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'CloudLicenseApp',
  components: {
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
  },
};
</script>

<template>
  <div
    class="gl-w-half gl-mx-auto gl-display-flex gl-justify-content-center gl-text-center gl-flex-direction-column"
  >
    <h3 class="gl-mt-6 gl-font-weight-bold">
      {{ __('This instance is currently using the Core plan.') }}
    </h3>

    <gl-form class="gl-mt-7">
      <gl-form-group
        id="activation-code-group"
        label="Paste your activation code below"
        label-for="activation-code-input"
      >
        <gl-form-input
          id="activation-code-input"
          required
          :placeholder="__('Paste your activation code')"
        />
      </gl-form-group>

      <div class="gl-display-flex gl-justify-content-end">
        <gl-button type="reset" class="gl-mr-3">{{ __('Cancel') }}</gl-button>
        <gl-button
          class="gl-mr-3"
          category="primary"
          variant="confirm"
          data-testid="activate-button"
          @click.prevent="go"
        >
          {{ __('Activate') }}
        </gl-button>
      </div>
    </gl-form>
  </div>
</template>
