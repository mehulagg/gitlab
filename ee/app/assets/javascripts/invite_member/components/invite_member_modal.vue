<script>
import { GlModal, GlLink, GlSprintf } from '@gitlab/ui';
import eventHub from '../event_hub';
import { s__, __ } from '~/locale';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  modalTitle: s__("InviteMember|Oops, this feature isn't ready yet"),
  bodyTopMessage: s__(
    `InviteMember|We're working to allow everyone to invite new members, making it easier for teams to get started with GitLab`,
  ),
  bodyMiddleMessage: s__(
    `InviteMember|Until then, ask an owner to invite new project members for you`,
  ),
  cancelProps: {
    text: __('Got it'),
    attributes: [
      {
        variant: 'info',
        'data-track-event': 'click_dismiss',
        'data-track-label': 'invite_members_message',
      },
    ],
  },
  components: {
    GlLink,
    GlModal,
    GlSprintf,
  },
  mixins: [trackingMixin],
  inject: {
    membersPath: {
      default: '',
    },
  },
  data() {
    return {
      modalId: 'invite-member-modal',
      trackLabel: 'invite_members_message',
    };
  },
  computed: {
    tracking() {
      return {
        label: this.trackLabel,
        event: 'feature_not_ready_message_shown',
      };
    },
  },
  mounted() {
    eventHub.$on('openModal', this.openModal);
    this.track();
  },
  methods: {
    openModal() {
      this.$root.$emit('bv::show::modal', this.modalId);
    },
  },
};
</script>
<template>
  <gl-modal :modal-id="modalId" size="sm" :action-cancel="$options.cancelProps">
    <template #modal-title>
      <gl-sprintf :message="$options.modalTitle" />
      <gl-emoji
        class="gl-vertical-align-baseline font-size-inherit gl-mr-1"
        data-name="sweat_smile"
      />
    </template>
    <p>
      <gl-sprintf :message="$options.bodyTopMessage" />
    </p>
    <p>
      <gl-sprintf :message="$options.bodyMiddleMessage" />
    </p>
    <gl-link
      :href="membersPath"
      data-track-event="click_who_can_invite_link"
      :data-track-label="trackLabel"
      >{{ __('See who can invite members for you') }}</gl-link
    >
  </gl-modal>
</template>
