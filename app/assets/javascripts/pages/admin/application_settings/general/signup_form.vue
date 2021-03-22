<script>
/* eslint-disable vue/no-v-html */

import { GlButton, GlFormGroup, GlFormInput, GlFormRadio, GlFormRadioGroup } from '@gitlab/ui';
import { escape } from 'lodash';
import csrf from '~/lib/utils/csrf';
import { s__, sprintf } from '~/locale';
import SignupCheckbox from './signup_checkbox.vue';

const DENYLIST_TYPE_RAW = 'raw';
const DENYLIST_TYPE_FILE = 'file';

export default {
  csrf,
  DENYLIST_TYPE_RAW,
  DENYLIST_TYPE_FILE,
  components: {
    GlButton,
    GlFormGroup,
    GlFormInput,
    GlFormRadio,
    GlFormRadioGroup,
    SignupCheckbox,
  },
  props: {
    host: {
      type: String,
      required: true,
    },
    settingsPath: {
      type: String,
      required: true,
    },
    signupEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    requireAdminApprovalAfterUserSignup: {
      type: Boolean,
      required: false,
      default: false,
    },
    sendUserConfirmationEmail: {
      type: Boolean,
      required: false,
      default: false,
    },
    minimumPasswordLength: {
      type: String,
      required: true,
    },
    minimumPasswordLengthMin: {
      type: String,
      required: true,
    },
    minimumPasswordLengthMax: {
      type: String,
      required: true,
    },
    minimumPasswordLengthHelpLink: {
      type: String,
      required: true,
    },
    domainAllowlistRaw: {
      type: String,
      required: false,
      default: '',
    },
    newUserSignupsCap: {
      type: String,
      required: true,
    },
    domainDenylistEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    denylistTypeRawSelected: {
      type: Boolean,
      required: false,
      default: false,
    },
    domainDenylistRaw: {
      type: String,
      required: false,
      default: '',
    },
    emailRestrictionsEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    supportedSyntaxLinkUrl: {
      type: String,
      required: true,
    },
    emailRestrictions: {
      type: String,
      required: true,
    },
    afterSignUpText: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      form: {
        signupEnabled: this.signupEnabled,
        requireAdminApproval: this.requireAdminApprovalAfterUserSignup,
        sendConfirmationEmail: this.sendUserConfirmationEmail,
        minimumPasswordLength: this.minimumPasswordLength,
        minimumPasswordLengthMin: this.minimumPasswordLengthMin,
        minimumPasswordLengthMax: this.minimumPasswordLengthMax,
        minimumPasswordLengthHelpLink: this.minimumPasswordLengthHelpLink,
        domainAllowlistRaw: this.domainAllowlistRaw,
        userCap: this.newUserSignupsCap,
        domainDenylistEnabled: this.domainDenylistEnabled,
        denylistType: this.denylistTypeRawSelected
          ? this.$options.DENYLIST_TYPE_RAW
          : this.$options.DENYLIST_TYPE_FILE,
        denylistRaw: this.domainDenylistRaw,
        emailRestrictionsEnabled: this.emailRestrictionsEnabled,
        supportedSyntaxLinkUrl: this.supportedSyntaxLinkUrl,
        emailRestrictions: this.emailRestrictions,
        afterSignUpText: this.afterSignUpText,
      },
    };
  },
  computed: {
    signupEnabledHelpText() {
      const text = sprintf(
        s__('When enabled, any user visiting %{host} will be able to create an account.'),
        {
          host: this.host,
        },
      );

      return text;
    },
    requireAdminApprovalHelpText() {
      const text = sprintf(
        s__(
          'When enabled, any user visiting %{host} and creating an account will have to be explicitly approved by an admin before they can sign in. This setting is effective only if sign-ups are enabled.',
        ),
        {
          host: this.host,
        },
      );

      return text;
    },
    minimumPasswordLengthDescription() {
      const text = sprintf(
        s__("See GitLab's %{linkStart}%{linkText}%{linkEnd}"),
        {
          linkText: s__('Password Policy Guidelines'),
          linkStart: `<a href="${escape(
            this.form.minimumPasswordLengthHelpLink,
          )}" rel="noopener noreferrer nofollow" target="_blank">`,
          linkEnd: '</a>',
        },
        false,
      );

      return text;
    },
    emailRestrictionsGroupDescription() {
      const text = sprintf(
        s__(
          'Restricts sign-ups for email addresses that match the given regex. See the %{linkStart}%{linkText}%{linkEnd} for more information.',
        ),
        {
          linkText: s__('supported syntax'),
          linkStart: `<a href="${escape(
            this.form.supportedSyntaxLinkUrl,
          )}" rel="noopener noreferrer nofollow" target="_blank">`,
          linkEnd: '</a>',
        },
        false,
      );

      return text;
    },
  },
  i18n: {
    buttonText: s__('Save changes'),
    signupEnabledLabel: s__('Sign-up enabled'),
    requireAdminApprovalLabel: s__('Require admin approval for new sign-ups'),
    sendConfirmationEmailLabel: s__('Send confirmation email on sign-up'),
    minimumPasswordLengthLabel: s__('Minimum password length (number of characters)'),
    domainAllowListLabel: s__('Allowed domains for sign-ups'),
    domainAllowListDescription: s__(
      'ONLY users with e-mail addresses that match these domain(s) will be able to sign-up. Wildcards allowed. Use separate lines for multiple entries. Ex: domain.com, *.domain.com',
    ),
    userCapLabel: s__('User cap'),
    userCapDescription: s__(
      'Once the instance reaches the user cap, any user who is added or requests access will have to be approved by an admin. Leave the field empty for unlimited.',
    ),
    domainDenyListGroupLabel: s__('Domain denylist'),
    domainDenyListLabel: s__('Enable domain denylist for sign ups'),
    domainDenyListTypeFileLabel: s__('Upload denylist file'),
    domainDenyListTypeRawLabel: s__('Enter denylist manually'),
    domainDenyListFileLabel: s__('Denylist file'),
    domainDenyListFileDescription: s__(
      'Users with e-mail addresses that match these domain(s) will NOT be able to sign-up. Wildcards allowed. Use separate lines or commas for multiple entries.',
    ),
    domainDenyListListLabel: s__('Denied domains for sign-ups'),
    domainDenyListListDescription: s__(
      'Users with e-mail addresses that match these domain(s) will NOT be able to sign-up. Wildcards allowed. Use separate lines for multiple entries. Ex: domain.com, *.domain.com',
    ),
    domainPlaceholder: s__('domain.com'),
    emailRestrictionsEnabledGroupLabel: s__('Email restrictions'),
    emailRestrictionsEnabledLabel: s__('Enable email restrictions for sign ups'),
    emailRestrictionsGroupLabel: s__('Email restrictions for sign-ups'),
    afterSignUpTextGroupLabel: s__('After sign up text'),
    afterSignUpTextGroupDescription: s__('Markdown enabled'),
  },
};
</script>

<template>
  <form :action="settingsPath" method="post" enctype="multipart/form-data" accept-charset="UTF-8">
    <input type="hidden" name="utf8" value="✓" />
    <input type="hidden" name="_method" value="patch" />
    <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />

    <signup-checkbox
      v-model="form.signupEnabled"
      class="gl-mb-5"
      name="application_setting[signup_enabled]"
      :help-text="signupEnabledHelpText"
      :label="$options.i18n.signupEnabledLabel"
      data-qa-selector="signup_enabled_checkbox"
    />

    <signup-checkbox
      v-model="form.requireAdminApproval"
      class="gl-mb-5"
      name="application_setting[require_admin_approval_after_user_signup]"
      :help-text="requireAdminApprovalHelpText"
      :label="$options.i18n.requireAdminApprovalLabel"
      data-qa-selector="require_admin_approval_after_user_signup_checkbox"
    />

    <signup-checkbox
      v-model="form.sendConfirmationEmail"
      class="gl-mb-5"
      name="application_setting[send_user_confirmation_email]"
      :label="$options.i18n.sendConfirmationEmailLabel"
    />

    <gl-form-group
      :label="$options.i18n.userCapLabel"
      :description="$options.i18n.userCapDescription"
    >
      <gl-form-input
        id="test_dummy"
        v-model="form.userCap"
        type="text"
        name="application_setting[new_user_signups_cap]"
      />
    </gl-form-group>

    <gl-form-group :label="$options.i18n.minimumPasswordLengthLabel">
      <gl-form-input
        v-model="form.minimumPasswordLength"
        :min="form.minimumPasswordLengthMin"
        :max="form.minimumPasswordLengthMax"
        type="number"
        name="application_setting[minimum_password_length]"
      />

      <template #description><span v-html="minimumPasswordLengthDescription"></span></template>
    </gl-form-group>

    <gl-form-group
      :description="$options.i18n.domainAllowListDescription"
      :label="$options.i18n.domainAllowListLabel"
    >
      <textarea
        v-model="form.domainAllowlistRaw"
        :placeholder="$options.i18n.domainPlaceholder"
        rows="8"
        class="form-control gl-form-input"
        name="application_setting[domain_allowlist_raw]"
      ></textarea>
    </gl-form-group>

    <gl-form-group :label="$options.i18n.domainDenyListGroupLabel">
      <signup-checkbox
        v-model="form.domainDenylistEnabled"
        name="application_setting[domain_denylist_enabled]"
        :label="$options.i18n.domainDenyListLabel"
      />
    </gl-form-group>

    <gl-form-radio-group v-model="form.denylistType" name="denylist_type" class="gl-mb-5">
      <gl-form-radio :value="$options.DENYLIST_TYPE_FILE">{{
        $options.i18n.domainDenyListTypeFileLabel
      }}</gl-form-radio>
      <gl-form-radio :value="$options.DENYLIST_TYPE_RAW">{{
        $options.i18n.domainDenyListTypeRawLabel
      }}</gl-form-radio>
    </gl-form-radio-group>

    <gl-form-group
      v-if="form.denylistType === $options.DENYLIST_TYPE_FILE"
      :description="$options.i18n.domainDenyListFileDescription"
      :label="$options.i18n.domainDenyListFileLabel"
      label-for="domain-denylist-file-input"
    >
      <input
        id="domain-denylist-file-input"
        class="form-control gl-form-input"
        type="file"
        accept=".txt,.conf"
        name="application_setting[domain_denylist_file]"
      />
    </gl-form-group>

    <gl-form-group
      v-if="form.denylistType !== $options.DENYLIST_TYPE_FILE"
      :description="$options.i18n.domainDenyListListDescription"
      :label="$options.i18n.domainDenyListListLabel"
    >
      <textarea
        v-model="form.denylistRaw"
        :placeholder="$options.i18n.domainPlaceholder"
        rows="8"
        class="form-control gl-form-input"
        name="application_setting[domain_denylist_raw]"
      ></textarea>
    </gl-form-group>

    <gl-form-group :label="$options.i18n.emailRestrictionsEnabledGroupLabel">
      <signup-checkbox
        v-model="form.emailRestrictionsEnabled"
        name="application_setting[email_restrictions_enabled]"
        :label="$options.i18n.emailRestrictionsEnabledLabel"
      />
    </gl-form-group>

    <gl-form-group :label="$options.i18n.emailRestrictionsGroupLabel">
      <textarea
        v-model="form.emailRestrictions"
        rows="4"
        class="form-control gl-form-input"
        name="application_setting[email_restrictions]"
      ></textarea>

      <template #description><span v-html="emailRestrictionsGroupDescription"></span></template>
    </gl-form-group>

    <gl-form-group
      :label="$options.i18n.afterSignUpTextGroupLabel"
      :description="$options.i18n.afterSignUpTextGroupDescription"
      class="gl-mb-5"
    >
      <textarea
        v-model="form.afterSignUpText"
        rows="4"
        class="form-control gl-form-input"
        name="application_setting[after_sign_up_text]"
      ></textarea>
    </gl-form-group>

    <gl-button data-qa-selector="save_changes_button" variant="confirm" type="submit">{{
      $options.i18n.buttonText
    }}</gl-button>
  </form>
</template>
