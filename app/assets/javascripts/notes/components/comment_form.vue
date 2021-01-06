<script>
import $ from 'jquery';
import { mapActions, mapGetters, mapState } from 'vuex';
import { isEmpty } from 'lodash';
import Autosize from 'autosize';
import { GlButton, GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import TimelineEntryItem from '~/vue_shared/components/notes/timeline_entry_item.vue';
import { deprecatedCreateFlash as Flash } from '~/flash';
import Autosave from '~/autosave';
import {
  capitalizeFirstCharacter,
  convertToCamelCase,
  splitCamelCase,
  slugifyWithUnderscore,
} from '~/lib/utils/text_utility';
import { refreshUserMergeRequestCounts } from '~/commons/nav/user_merge_requests';
import * as constants from '../constants';
import eventHub from '../event_hub';
import NoteableWarning from '~/vue_shared/components/notes/noteable_warning.vue';
import markdownField from '~/vue_shared/components/markdown/field.vue';
import userAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import noteSignedOutWidget from './note_signed_out_widget.vue';
import discussionLockedWidget from './discussion_locked_widget.vue';
import issuableStateMixin from '../mixins/issuable_state';

export default {
  name: 'CommentForm',
  i18n: {
    submitButton: {
      startThread: __('Start thread'),
      comment: __('Comment'),
      commentHelp: __('Add a general comment to this %{noteableDisplayName}.'),
    },
  },
  noteTypeComment: constants.COMMENT,
  noteTypeDiscussion: constants.DISCUSSION,
  components: {
    NoteableWarning,
    noteSignedOutWidget,
    discussionLockedWidget,
    markdownField,
    userAvatarLink,
    GlButton,
    TimelineEntryItem,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
  },
  mixins: [glFeatureFlagsMixin(), issuableStateMixin],
  props: {
    noteableType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      note: '',
      noteType: constants.COMMENT,
      isSubmitting: false,
      isSubmitButtonDisabled: true,
    };
  },
  computed: {
    ...mapGetters([
      'getCurrentUserLastNote',
      'getUserData',
      'getNoteableData',
      'getNoteableDataByProp',
      'getNotesData',
      'openState',
    ]),
    ...mapState(['isToggleStateButtonLoading']),
    isNoteTypeComment() {
      return this.noteType === constants.COMMENT;
    },
    isNoteTypeDiscussion() {
      return this.noteType === constants.DISCUSSION;
    },
    noteableDisplayName() {
      return splitCamelCase(this.noteableType).toLowerCase();
    },
    isLoggedIn() {
      return this.getUserData.id;
    },
    commentButtonTitle() {
      return this.noteType === constants.COMMENT ? __('Comment') : __('Start thread');
    },
    startDiscussionDescription() {
      return this.getNoteableData.noteableType === constants.MERGE_REQUEST_NOTEABLE_TYPE
        ? __('Discuss a specific suggestion or question that needs to be resolved.')
        : __('Discuss a specific suggestion or question.');
    },
    commentDescription() {
      return sprintf(this.$options.i18n.submitButton.commentHelp, {
        noteableDisplayName: this.noteableDisplayName,
      });
    },
    isOpen() {
      return this.openState === constants.OPENED || this.openState === constants.REOPENED;
    },
    canCreateNote() {
      return this.getNoteableData.current_user.can_create_note;
    },
    issueActionButtonTitle() {
      const openOrClose = this.isOpen ? 'close' : 'reopen';

      if (this.note.length) {
        return sprintf(__('%{actionText} & %{openOrClose} %{noteable}'), {
          actionText: this.commentButtonTitle,
          openOrClose,
          noteable: this.noteableDisplayName,
        });
      }

      return sprintf(__('%{openOrClose} %{noteable}'), {
        openOrClose: capitalizeFirstCharacter(openOrClose),
        noteable: this.noteableDisplayName,
      });
    },
    buttonVariant() {
      return this.isOpen ? 'warning' : 'default';
    },
    actionButtonClassNames() {
      return {
        'btn-reopen': !this.isOpen,
        'btn-close': this.isOpen,
        'js-note-target-close': this.isOpen,
        'js-note-target-reopen': !this.isOpen,
      };
    },
    markdownDocsPath() {
      return this.getNotesData.markdownDocsPath;
    },
    quickActionsDocsPath() {
      return this.getNotesData.quickActionsDocsPath;
    },
    markdownPreviewPath() {
      return this.getNoteableData.preview_note_path;
    },
    author() {
      return this.getUserData;
    },
    canToggleIssueState() {
      return (
        this.getNoteableData.current_user.can_update &&
        this.getNoteableData.state !== constants.MERGED &&
        !this.closedAndLocked
      );
    },
    closedAndLocked() {
      return !this.isOpen && this.isLocked(this.getNoteableData);
    },
    endpoint() {
      return this.getNoteableData.create_note_path;
    },
    issuableTypeTitle() {
      return this.noteableType === constants.MERGE_REQUEST_NOTEABLE_TYPE
        ? __('merge request')
        : __('issue');
    },
    isIssue() {
      return this.noteableDisplayName === constants.ISSUE_NOTEABLE_TYPE;
    },
    trackingLabel() {
      return slugifyWithUnderscore(`${this.commentButtonTitle} button`);
    },
  },
  watch: {
    note(newNote) {
      this.setIsSubmitButtonDisabled(newNote, this.isSubmitting);
    },
    isSubmitting(newValue) {
      this.setIsSubmitButtonDisabled(this.note, newValue);
    },
  },
  mounted() {
    // jQuery is needed here because it is a custom event being dispatched with jQuery.
    $(document).on('issuable:change', (e, isClosed) => {
      this.toggleIssueLocalState(isClosed ? constants.CLOSED : constants.REOPENED);
    });

    this.initAutoSave();
  },
  methods: {
    ...mapActions([
      'saveNote',
      'stopPolling',
      'restartPolling',
      'removePlaceholderNotes',
      'closeIssuable',
      'reopenIssuable',
      'toggleIssueLocalState',
    ]),
    setIsSubmitButtonDisabled(note, isSubmitting) {
      if (!isEmpty(note) && !isSubmitting) {
        this.isSubmitButtonDisabled = false;
      } else {
        this.isSubmitButtonDisabled = true;
      }
    },
    handleSave(withIssueAction) {
      if (this.note.length) {
        const noteData = {
          endpoint: this.endpoint,
          flashContainer: this.$el,
          data: {
            note: {
              noteable_type: this.noteableType,
              noteable_id: this.getNoteableData.id,
              note: this.note,
            },
            merge_request_diff_head_sha: this.getNoteableData.diff_head_sha,
          },
        };

        if (this.noteType === constants.DISCUSSION) {
          noteData.data.note.type = constants.DISCUSSION_NOTE;
        }

        this.note = ''; // Empty textarea while being requested. Repopulate in catch
        this.resizeTextarea();
        this.stopPolling();

        this.isSubmitting = true;

        this.saveNote(noteData)
          .then(() => {
            this.restartPolling();
            this.discard();

            if (withIssueAction) {
              this.toggleIssueState();
            }
          })
          .catch(() => {
            this.discard(false);
            const msg = __(
              'Your comment could not be submitted! Please check your network connection and try again.',
            );
            Flash(msg, 'alert', this.$el);
            this.note = noteData.data.note.note; // Restore textarea content.
            this.removePlaceholderNotes();
          })
          .finally(() => {
            this.isSubmitting = false;
          });
      } else {
        this.toggleIssueState();
      }
    },
    toggleIssueState() {
      if (this.isIssue) {
        // We want to invoke the close/reopen logic in the issue header
        // since that is where the blocked-by issues modal logic is also defined
        eventHub.$emit('toggle.issuable.state');
        return;
      }

      const toggleState = this.isOpen ? this.closeIssuable : this.reopenIssuable;

      toggleState()
        .then(refreshUserMergeRequestCounts)
        .catch(() => Flash(constants.toggleStateErrorMessage[this.noteableType][this.openState]));
    },
    discard(shouldClear = true) {
      // `blur` is needed to clear slash commands autocomplete cache if event fired.
      // `focus` is needed to remain cursor in the textarea.
      this.$refs.textarea.blur();
      this.$refs.textarea.focus();

      if (shouldClear) {
        this.note = '';
        this.resizeTextarea();
        this.$refs.markdownField.previewMarkdown = false;
      }

      this.autosave.reset();
    },
    setNoteType(type) {
      this.noteType = type;
    },
    setNoteTypeToComment() {
      this.setNoteType(constants.COMMENT);
    },
    setNoteTypeToDiscussion() {
      this.setNoteType(constants.DISCUSSION);
    },
    editCurrentUserLastNote() {
      if (this.note === '') {
        const lastNote = this.getCurrentUserLastNote;

        if (lastNote) {
          eventHub.$emit('enterEditMode', {
            noteId: lastNote.id,
          });
        }
      }
    },
    initAutoSave() {
      if (this.isLoggedIn) {
        const noteableType = capitalizeFirstCharacter(convertToCamelCase(this.noteableType));

        this.autosave = new Autosave($(this.$refs.textarea), [
          __('Note'),
          noteableType,
          this.getNoteableData.id,
        ]);
      }
    },
    resizeTextarea() {
      this.$nextTick(() => {
        Autosize.update(this.$refs.textarea);
      });
    },
  },
};
</script>

<template>
  <div>
    <note-signed-out-widget v-if="!isLoggedIn" />
    <discussion-locked-widget v-else-if="!canCreateNote" :issuable-type="issuableTypeTitle" />
    <ul v-else-if="canCreateNote" class="notes notes-form timeline">
      <timeline-entry-item class="note-form">
        <div class="flash-container error-alert timeline-content"></div>
        <div class="timeline-icon d-none d-md-block">
          <user-avatar-link
            v-if="author"
            :link-href="author.path"
            :img-src="author.avatar_url"
            :img-alt="author.name"
            :img-size="40"
          />
        </div>
        <div class="timeline-content timeline-content-form">
          <form ref="commentForm" class="new-note common-note-form gfm-form js-main-target-form">
            <div class="error-alert"></div>

            <noteable-warning
              v-if="hasWarning(getNoteableData)"
              :is-locked="isLocked(getNoteableData)"
              :is-confidential="isConfidential(getNoteableData)"
              :noteable-type="noteableType"
              :locked-noteable-docs-path="lockedIssueDocsPath"
              :confidential-noteable-docs-path="confidentialIssueDocsPath"
            />

            <markdown-field
              ref="markdownField"
              :is-submitting="isSubmitting"
              :markdown-preview-path="markdownPreviewPath"
              :markdown-docs-path="markdownDocsPath"
              :quick-actions-docs-path="quickActionsDocsPath"
              :add-spacing-classes="false"
              :textarea-value="note"
            >
              <textarea
                id="note-body"
                ref="textarea"
                slot="textarea"
                v-model="note"
                dir="auto"
                :disabled="isSubmitting"
                name="note[note]"
                class="note-textarea js-vue-comment-form js-note-text js-gfm-input js-autosize markdown-area"
                data-qa-selector="comment_field"
                data-testid="comment-field"
                :data-supports-quick-actions="!glFeatures.tributeAutocomplete"
                :aria-label="__('Description')"
                :placeholder="__('Write a comment or drag your files here…')"
                @keydown.up="editCurrentUserLastNote()"
                @keydown.meta.enter="handleSave()"
                @keydown.ctrl.enter="handleSave()"
              ></textarea>
            </markdown-field>

            <div class="note-form-actions">
              <gl-dropdown
                split
                :text="commentButtonTitle"
                class="gl-mr-3 js-comment-button js-comment-submit-button"
                category="primary"
                variant="success"
                :disabled="isSubmitButtonDisabled"
                data-testid="comment-button"
                data-qa-selector="comment_button"
                :data-track-label="trackingLabel"
                data-track-event="click_button"
                @click="handleSave()"
              >
                <gl-dropdown-item
                  is-check-item
                  :is-checked="isNoteTypeComment"
                  :selected="isNoteTypeComment"
                  @click="setNoteTypeToComment()"
                >
                  <strong>{{ $options.i18n.submitButton.comment }}</strong>
                  <div>{{ commentDescription }}</div>
                </gl-dropdown-item>
                <gl-dropdown-divider />
                <gl-dropdown-item
                  is-check-item
                  :is-checked="isNoteTypeDiscussion"
                  :selected="isNoteTypeDiscussion"
                  data-qa-selector="discussion_menu_item"
                  @click="setNoteTypeToDiscussion()"
                >
                  <strong>{{ $options.i18n.submitButton.startThread }}</strong>
                  <div>{{ startDiscussionDescription }}</div>
                </gl-dropdown-item>
              </gl-dropdown>
              <gl-button
                v-if="canToggleIssueState"
                :loading="isToggleStateButtonLoading"
                category="secondary"
                :variant="buttonVariant"
                :class="[actionButtonClassNames, 'btn-comment btn-comment-and-close']"
                :disabled="isSubmitting"
                data-testid="close-reopen-button"
                @click="handleSave(true)"
                >{{ issueActionButtonTitle }}</gl-button
              >
            </div>
          </form>
        </div>
      </timeline-entry-item>
    </ul>
  </div>
</template>
