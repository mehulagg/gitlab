<script>
import { GlForm, GlButton, GlCard } from '@gitlab/ui';
import InviteMembers from 'ee/groups/components/invite_members.vue';
import csrf from '~/lib/utils/csrf';
import { s__ } from '~/locale';

export default {
  components: {
    GlCard,
    GlForm,
    GlButton,
    InviteMembers,
  },
  inject: {
    endpoint: {
      default: '',
    },
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
  },
  i18n: {
    inviteAnother: s__('InviteMember|Invite another teammate'),
    sendInvitations: s__('InviteMember|Send invitations'),
  },
  csrf,
};
</script>
<template>
  <gl-card>
    <gl-form ref="form" :action="endpoint" method="post">
      <input type="hidden" name="authenticity_token" :value="$options.csrf.token" />
      <invite-members
        :docs-path="docsPath"
        :emails="emails"
        :initial-email-inputs="3"
        email-placeholder-prefix="teammate"
        :add-another-text="$options.i18n.inviteAnother"
        input-name="emails[]"
      />
      <gl-button type="submit" variant="success" class="gl-w-full!">
        {{ $options.i18n.sendInvitations }}
      </gl-button>
    </gl-form>
  </gl-card>
</template>
