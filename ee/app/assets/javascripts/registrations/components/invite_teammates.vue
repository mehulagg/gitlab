<script>
import { GlFormGroup, GlFormInput, GlButton } from '@gitlab/ui';
import { __, sprintf } from '~/locale';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlButton,
  },
  props: {
    emails: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      numberOfInputs: Math.max(this.emails.length, 2),
    };
  },
  methods: {
    addInput() {
      this.numberOfInputs += 1;
      this.$nextTick(() => {
        this.$refs[this.emailID(this.numberOfInputs)][0].$el.focus();
      });
    },
    emailLabel(number) {
      return sprintf(this.$options.i18n.emailLabel, { number });
    },
    emailPlaceholder(number) {
      return sprintf(this.$options.i18n.emailPlaceholder, { number });
    },
    emailID(number) {
      return `email-${number}`;
    },
  },
  i18n: {
    inviteTeammatesLabel: __('Invite teammates (optional)'),
    inviteTeammatesDescription: __(
      'Invited users will be added with developer level permissions. You can always change this later.',
    ),
    emailLabel: __('Email %{number}'),
    emailPlaceholder: __('teammate%{number}@company.com'),
    inviteAnother: __('Invite another teammate'),
  },
};
</script>
<template>
  <div class="gl-mb-6">
    <gl-form-group
      :label="$options.i18n.inviteTeammatesLabel"
      :description="$options.i18n.inviteTeammatesDescription"
    />
    <gl-form-group
      v-for="(number, index) in numberOfInputs"
      :key="number"
      :label="emailLabel(number)"
      :label-for="emailID(number)"
    >
      <gl-form-input
        :id="emailID(number)"
        :ref="emailID(number)"
        name="group[emails][]"
        :placeholder="emailPlaceholder(number)"
        :value="emails[index]"
      />
    </gl-form-group>
    <gl-button icon="plus" @click="addInput">{{ $options.i18n.inviteAnother }}</gl-button>
  </div>
</template>
