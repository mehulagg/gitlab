<script>
import { GlFormGroup, GlFormInput, GlButton, GlSprintf, GlLink } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlButton,
    GlSprintf,
    GlLink,
  },
  props: {
    docsPath: {
      type: String,
      required: true,
    },
    emails: {
      type: Array,
      required: true,
    },
    initialEmailInputs: {
      type: Number,
      required: false,
      default: 1,
    },
    emailPlaceholderPrefix: {
      type: String,
      required: false,
      default: 'member',
    },
    addAnotherText: {
      type: String,
      required: false,
      default: s__('InviteMember|Invite another member'),
    },
    inviteLabel: {
      type: String,
      required: false,
      default: '',
    },
    inputName: {
      type: String,
      required: false,
      default: 'group[emails][]',
    },
  },
  data() {
    return {
      numberOfInputs: Math.max(this.emails.length, this.initialEmailInputs),
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
      const emailPrefix = this.emailPlaceholderPrefix + number;

      return sprintf(this.$options.i18n.emailPlaceholder, { emailPrefix });
    },
    emailID(number) {
      return `email-${number}`;
    },
  },
  i18n: {
    inviteMembersLabel: s__('InviteMember|Invite Members (optional)'),
    inviteMembersDescription: s__(
      'InviteMember|Invited users will be added with developer level permissions. %{linkStart}View the documentation%{linkEnd} to see how to change this later.',
    ),
    emailLabel: __('Email %{number}'),
    emailPlaceholder: __('%{emailPrefix}@company.com'),
    inviteAnother: s__('InviteMember|Invite another member'),
  },
};
</script>
<template>
  <div class="gl-mb-6">
    <gl-form-group :label="inviteLabel" data-testid="no-input-form-group">
      <template #description>
        <gl-sprintf :message="$options.i18n.inviteMembersDescription">
          <template #link="{ content }">
            <gl-link :href="docsPath" target="_blank">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </template>
    </gl-form-group>
    <gl-form-group
      v-for="(number, index) in numberOfInputs"
      :key="number"
      :label="emailLabel(number)"
      :label-for="emailID(number)"
    >
      <gl-form-input
        :id="emailID(number)"
        :ref="emailID(number)"
        :name="inputName"
        :placeholder="emailPlaceholder(number)"
        :value="emails[index]"
      />
    </gl-form-group>
    <gl-button icon="plus" @click="addInput">{{ addAnotherText }}</gl-button>
  </div>
</template>
