<script>
import { GlBanner } from '@gitlab/ui';
import { parseBoolean, setCookie, getCookie } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';
import Tracking from '~/tracking';
import InviteMembersTrigger from '~/invite_members/components/invite_members_trigger.vue';

const trackingMixin = Tracking.mixin();

export default {
  components: {
    GlBanner,
    InviteMembersTrigger,
  },
  mixins: [trackingMixin],
  inject: ['svgPath', 'isDismissedKey', 'trackLabel'],
  data() {
    return {
      isDismissed: parseBoolean(getCookie(this.isDismissedKey)),
      tracking: {
        label: this.trackLabel,
      },
    };
  },
  created() {
    this.$nextTick(() => {
      this.addTrackingAttributesToButton();
    });
  },
  mounted() {
    this.trackOnShow();
  },
  methods: {
    handleClose() {
      setCookie(this.isDismissedKey, true);
      this.isDismissed = true;
      this.track(this.$options.dismissEvent);
    },
    trackOnShow() {
      this.$nextTick(() => {
        if (!this.isDismissed) this.track(this.$options.displayEvent);
      });
    },
    addTrackingAttributesToButton() {
      if (this.$refs.banner === undefined) return;

      const button = this.$refs.banner.$el.querySelector(`[href='${this.inviteMembersPath}']`);

      if (button) {
        button.setAttribute('data-track-event', this.$options.buttonClickEvent);
        button.setAttribute('data-track-label', this.trackLabel);
      }
    },
  },
  i18n: {
    title: s__('InviteMembersBanner|Collaborate with your team'),
    body: s__(
      "InviteMembersBanner|We noticed that you haven't invited anyone to this group. Invite your colleagues so you can discuss issues, collaborate on merge requests, and share your knowledge.",
    ),
    button_text: s__('InviteMembersBanner|Invite your colleagues'),
  },
  displayEvent: 'invite_members_banner_displayed',
  buttonClickEvent: 'invite_members_banner_button_clicked',
  dismissEvent: 'invite_members_banner_dismissed',
};
</script>

<template>
  <gl-banner
    v-if="!isDismissed"
    ref="banner"
    :title="$options.i18n.title"
    :svg-path="svgPath"
    @close="handleClose"
  >
    <p>{{ $options.i18n.body }}</p>
    <template #actions>
      <invite-members-trigger
        classes="btn-confirm"
        :display-text="$options.i18n.button_text"
       />
    </template>
  </gl-banner>
</template>
