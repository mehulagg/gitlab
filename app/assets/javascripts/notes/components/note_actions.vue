<script>
import { mapGetters } from 'vuex';
import { GlLoadingIcon, GlTooltipDirective, GlIcon, GlButton, GlDropdownItem, GlDropdown, } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import resolvedStatusMixin from '~/batch_comments/mixins/resolved_status';
import ReplyButton from './note_actions/reply_button.vue';
import eventHub from '~/sidebar/event_hub';
import Api from '~/api';
import { deprecatedCreateFlash as flash } from '~/flash';
import { splitCamelCase } from '../../lib/utils/text_utility';
import { stringifyTime } from '../../lib/utils/datetime_utility';

export default {
  name: 'NoteActions',
  components: {
    GlIcon,
    ReplyButton,
    GlLoadingIcon,
    GlButton,
    GlDropdownItem,
    GlDropdown,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [resolvedStatusMixin],
  props: {
    author: {
      type: Object,
      required: true,
    },
    authorId: {
      type: Number,
      required: true,
    },
    noteId: {
      type: [String, Number],
      required: true,
    },
    noteUrl: {
      type: String,
      required: false,
      default: '',
    },
    accessLevel: {
      type: String,
      required: false,
      default: '',
    },
    reportAbusePath: {
      type: String,
      required: false,
      default: null,
    },
    isAuthor: {
      type: Boolean,
      required: false,
      default: false,
    },
    isContributor: {
      type: Boolean,
      required: false,
      default: false,
    },
    noteableType: {
      type: String,
      required: false,
      default: '',
    },
    projectName: {
      type: String,
      required: false,
      default: '',
    },
    showReply: {
      type: Boolean,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: true,
    },
    canAwardEmoji: {
      type: Boolean,
      required: true,
    },
    canDelete: {
      type: Boolean,
      required: true,
    },
    canResolve: {
      type: Boolean,
      required: false,
      default: false,
    },
    resolvable: {
      type: Boolean,
      required: false,
      default: false,
    },
    isResolved: {
      type: Boolean,
      required: false,
      default: false,
    },
    isResolving: {
      type: Boolean,
      required: false,
      default: false,
    },
    resolvedBy: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    canReportAsAbuse: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['getUserDataByProp', 'getNoteableData']),
    shouldShowActionsDropdown() {
      return this.currentUserId && (this.canEdit || this.canReportAsAbuse);
    },
    showDeleteAction() {
      return this.canDelete && !this.canReportAsAbuse && !this.noteUrl;
    },
    isAuthoredByCurrentUser() {
      return this.authorId === this.currentUserId;
    },
    currentUserId() {
      return this.getUserDataByProp('id');
    },
    isUserAssigned() {
      return this.assignees && this.assignees.some(({ id }) => id === this.author.id);
    },
    displayAssignUserText() {
      return this.isUserAssigned
        ? __('Unassign from commenting user')
        : __('Assign to commenting user');
    },
    sidebarAction() {
      return this.isUserAssigned ? 'sidebar.addAssignee' : 'sidebar.removeAssignee';
    },
    targetType() {
      return this.getNoteableData.targetType;
    },
    noteableDisplayName() {
      return splitCamelCase(this.noteableType).toLowerCase();
    },
    assignees() {
      return this.getNoteableData.assignees || [];
    },
    isIssue() {
      return this.targetType === 'issue';
    },
    canAssign() {
      return this.getNoteableData.current_user?.can_update && this.isIssue;
    },
    displayAuthorBadgeText() {
      return sprintf(__('This user is the author of this %{noteable}.'), {
        noteable: this.noteableDisplayName,
      });
    },
    displayMemberBadgeText() {
      return sprintf(__('This user is a %{access} of the %{name} project.'), {
        access: this.accessLevel.toLowerCase(),
        name: this.projectName,
      });
    },
    displayContributorBadgeText() {
      return sprintf(__('This user has previously committed to the %{name} project.'), {
        name: this.projectName,
      });
    },
    resolveIcon() {
      if (!this.isResolving) {
        return this.isResolved ? 'check-circle-filled' : 'check-circle';
      }
    },
    resolveVariant() {
      return this.isResolved ? 'success' : 'default';
    },
    isHover() {
      return $(':hover').filter($('a.js-add-award'));
    },
    awardIcon() {
      return this.isHover ? 'smiley' : 'slight-smile';
    },
  },
  methods: {
    onEdit() {
      this.$emit('handleEdit');
    },
    onDelete() {
      this.$emit('handleDelete');
    },
    onResolve() {
      this.$emit('handleResolve');
    },
    // handleMouseMove(e) {
    //   this.isHover = e.type === 'mouseover';
    // },
    closeTooltip() {
      this.$nextTick(() => {
        this.$root.$emit('bv::hide::tooltip');
      });
    },
    handleAssigneeUpdate(assignees) {
      this.$emit('updateAssignees', assignees);
      eventHub.$emit(this.sidebarAction, this.author);
      eventHub.$emit('sidebar.saveAssignees');
    },
    assignUser() {
      let { assignees } = this;
      const { project_id, iid } = this.getNoteableData;

      if (this.isUserAssigned) {
        assignees = assignees.filter(assignee => assignee.id !== this.author.id);
      } else {
        assignees.push({ id: this.author.id });
      }

      if (this.targetType === 'issue') {
        Api.updateIssue(project_id, iid, {
          assignee_ids: assignees.map(assignee => assignee.id),
        })
          .then(() => this.handleAssigneeUpdate(assignees))
          .catch(() => flash(__('Something went wrong while updating assignees')));
      }
    },
  },
};
</script>

<template>
  <div class="note-actions">
    <span
      v-if="isAuthor"
      class="note-role user-access-role has-tooltip d-none d-md-inline-block"
      :title="displayAuthorBadgeText"
      >{{ __('Author') }}</span
    >
    <span
      v-if="accessLevel"
      class="note-role user-access-role has-tooltip"
      :title="displayMemberBadgeText"
      >{{ accessLevel }}</span
    >
    <span
      v-else-if="isContributor"
      class="note-role user-access-role has-tooltip"
      :title="displayContributorBadgeText"
      >{{ __('Contributor') }}</span
    >
    <div v-if="canResolve">
      <gl-button
        ref="resolveButton"
        v-gl-tooltip
        category="tertiary"
        :variant="resolveVariant"
        :class="{ 'is-disabled': !resolvable, 'is-active': isResolved }"
        :title="resolveButtonTitle"
        :aria-label="resolveButtonTitle"
        :icon="resolveIcon"
        :loading="isResolving"
        class="line-resolve-btn note-action-button"
        @click="onResolve"
      />
    </div>
    <div v-if="canAwardEmoji">
      <gl-button
        v-gl-tooltip
        :class="{ 'js-user-authored': isAuthoredByCurrentUser }"
        class="note-action-button note-emoji-button js-add-award js-note-emoji"
        href="#"
        category="tertiary"
        title="Add reaction"
        data-position="right"
        :icon="awardIcon"
      />
        <!-- <gl-icon class="link-highlight award-control-icon-neutral" name="slight-smile" />
        <gl-icon class="link-highlight award-control-icon-positive" name="smiley" />
        <gl-icon class="link-highlight award-control-icon-super-positive" name="smiley" />
      </gl-button> -->
    </div>
    <reply-button
      v-if="showReply"
      ref="replyButton"
      class="js-reply-button"
      @startReplying="$emit('startReplying')"
    />
    <div v-if="canEdit">
      <gl-button
        v-gl-tooltip
        title="Edit comment"
        icon="pencil"
        category="tertiary"
        class="note-action-button js-note-edit btn btn-transparent qa-note-edit-button"
        @click="onEdit"
      />
    </div>
    <div v-if="showDeleteAction">
      <gl-button
        v-gl-tooltip
        title="Delete comment"
        icon="remove"
        category="tertiary"
        class="note-action-button js-note-delete btn btn-transparent"
        @click="onDelete"
      />
    </div>
    <div v-else-if="shouldShowActionsDropdown" class="dropdown">
      <gl-button
        v-gl-tooltip
        title="More actions"
        icon="ellipsis_v"
        category="tertiary"
        class="note-action-button more-actions-toggle btn btn-transparent"
        data-toggle="dropdown"
        @click="closeTooltip"
      />
      <ul class="dropdown-menu more-actions-dropdown dropdown-open-left">
        <gl-dropdown-item
          v-if="canReportAsAbuse"
          :href="reportAbusePath"
        >
          {{ __('Report abuse to admin') }}
        </gl-dropdown-item>
        <gl-dropdown-item
          v-if="noteUrl"
          :data-clipboard-text="noteUrl"
        >
          {{ __('Copy link') }}
        </gl-dropdown-item>
        <gl-dropdown-item
          v-if="canAssign"
          data-testid="assign-user"
          @click="assignUser"
        >
          {{ displayAssignUserText }}
        </gl-dropdown-item>
        <gl-dropdown-item
          v-if="canEdit"
          @click.prevent="onDelete"
        >
          <span class="text-danger">{{ __('Delete comment') }}</span>
        </gl-dropdown-item>
      </ul>
    </div>
  </div>
</template>
