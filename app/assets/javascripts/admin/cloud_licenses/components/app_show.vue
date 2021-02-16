<script>
import { GlButton, GlCard, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  name: 'CloudLicenseShowApp',
  components: {
    GlButton,
    GlCard,
    GlForm,
    GlFormGroup,
    GlFormInput,
  },
};
</script>

<template>
  <div class="gl-mt-3">
    <gl-card>
      <template #header>
        <h3 class="gl-my-0 gl-font-weight-bold">
          {{ __('This instance is currently using the Core plan.') }}
        </h3>
      </template>
      <gl-form>
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

        <gl-button
          class="mr-auto js-no-auto-disable"
          category="primary"
          variant="success"
          type="submit"
          data-testid="submit-button"
        >
          {{ __('Activate') }}
        </gl-button>
      </gl-form>
    </gl-card>
  </div>
</template>
