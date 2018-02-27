import Flash from '~/flash';
import LinkToMemberAvatar from 'ee/vue_shared/components/link_to_member_avatar';
import { s__ } from '~/locale';
import eventHub from '~/vue_merge_request_widget/event_hub';

export default {
  name: 'approvals-footer',
  props: {
    mr: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
    approvedBy: {
      type: Array,
      required: false,
    },
    approvalsLeft: {
      type: Number,
      required: false,
    },
    userCanApprove: {
      type: Boolean,
      required: false,
    },
    userHasApproved: {
      type: Boolean,
      required: false,
    },
    suggestedApprovers: {
      type: Array,
      required: false,
    },
  },
  data() {
    return {
      unapproving: false,
    };
  },
  components: {
    'link-to-member-avatar': LinkToMemberAvatar,
  },
  computed: {
    showUnapproveButton() {
      const isMerged = this.mr.state === 'merged';
      return this.userHasApproved && !this.userCanApprove && !isMerged;
    },
    approvedByText() {
      return s__('mrWidget|Approved by');
    },
    removeApprovalText() {
      return s__('mrWidget|Remove your approval');
    },
  },
  methods: {
    unapproveMergeRequest() {
      this.unapproving = true;
      this.service.unapproveMergeRequest()
        .then((data) => {
          this.mr.setApprovals(data);
          eventHub.$emit('MRWidgetUpdateRequested');
          this.unapproving = false;
        })
        .catch(() => {
          this.unapproving = false;
          Flash(s__('mrWidget|An error occured while removing your approval.'));
        });
    },
  },
  template: `
    <div
      v-if="approvedBy.length"
      class="approved-by-users approvals-footer clearfix mr-info-list">
      <div class="approvers-prefix">
        <p>{{approvedByText}}</p>
        <div class="approvers-list">
          <link-to-member-avatar
            v-for="(approver, index) in approvedBy"
            :key="index"
            :avatar-size="20"
            :avatar-url="approver.user.avatar_url"
            extra-link-class="approver-avatar js-approver-list-member"
            :display-name="approver.user.name"
            :profile-url="approver.user.web_url"
            :show-tooltip="true"
            />
          <link-to-member-avatar
            v-for="n in approvalsLeft"
            :key="n"
            :avatar-size="20"
            :clickable="false"
            :show-tooltip="false"
            />
        </div>
        <button
          v-if="showUnapproveButton"
          type="button"
          :disabled="unapproving"
          @click="unapproveMergeRequest"
          class="btn btn-sm unapprove-btn-wrap">
          <i
            v-if="unapproving"
            class="fa fa-spinner fa-spin"
            aria-hidden="true">
          </i>
          {{removeApprovalText}}
        </button>
      </div>
    </div>
  `,
};
