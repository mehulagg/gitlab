/* eslint-disable no-restricted-properties, func-names, space-before-function-paren, no-var, prefer-rest-params, wrap-iife, no-use-before-define, camelcase, no-unused-expressions, quotes, max-len, one-var, one-var-declaration-per-line, default-case, prefer-template, consistent-return, no-alert, no-return-assign, no-param-reassign, prefer-arrow-callback, no-else-return, comma-dangle, no-new, brace-style, no-lonely-if, vars-on-top, no-unused-vars, no-sequences, no-shadow, newline-per-chained-call, no-useless-escape */
/* global Flash */
/* global Autosave */
/* global ResolveService */
/* global mrRefreshWidgetUrl */

import $ from 'jquery';
import Cookies from 'js-cookie';
import CommentTypeToggle from './comment_type_toggle';
import normalizeNewlines from './lib/utils/normalize_newlines';

require('./autosave');
window.autosize = require('vendor/autosize');
window.Dropzone = require('dropzone');
require('./dropzone_input');
require('./gfm_auto_complete');
require('vendor/jquery.caret'); // required by jquery.atwho
require('vendor/jquery.atwho');
require('./task_list');

(function() {
  var bind = function(fn, me) { return function() { return fn.apply(me, arguments); }; };

  this.Notes = (function() {
    const MAX_VISIBLE_COMMIT_LIST_COUNT = 3;
    const REGEX_SLASH_COMMANDS = /^\/\w+.*$/gm;

    Notes.interval = null;

    function Notes(notes_url, note_ids, last_fetched_at, view) {
      this.updateTargetButtons = this.updateTargetButtons.bind(this);
      this.updateComment = this.updateComment.bind(this);
      this.visibilityChange = this.visibilityChange.bind(this);
      this.cancelDiscussionForm = this.cancelDiscussionForm.bind(this);
      this.onAddDiffNote = this.onAddDiffNote.bind(this);
      this.setupDiscussionNoteForm = this.setupDiscussionNoteForm.bind(this);
      this.onReplyToDiscussionNote = this.onReplyToDiscussionNote.bind(this);
      this.removeNote = this.removeNote.bind(this);
      this.cancelEdit = this.cancelEdit.bind(this);
      this.updateNote = this.updateNote.bind(this);
      this.addDiscussionNote = this.addDiscussionNote.bind(this);
      this.addNoteError = this.addNoteError.bind(this);
      this.addNote = this.addNote.bind(this);
      this.resetMainTargetForm = this.resetMainTargetForm.bind(this);
      this.refresh = this.refresh.bind(this);
      this.keydownNoteText = this.keydownNoteText.bind(this);
      this.toggleCommitList = this.toggleCommitList.bind(this);
      this.postComment = this.postComment.bind(this);

      this.notes_url = notes_url;
      this.note_ids = note_ids;
      // Used to keep track of updated notes while people are editing things
      this.updatedNotesTrackingMap = {};
      this.last_fetched_at = last_fetched_at;
      this.noteable_url = document.URL;
      this.notesCountBadge || (this.notesCountBadge = $(".issuable-details").find(".notes-tab .badge"));
      this.basePollingInterval = 15000;
      this.maxPollingSteps = 4;

      this.cleanBinding();
      this.addBinding();
      this.setPollingInterval();
      this.setupMainTargetNoteForm();
      this.taskList = new gl.TaskList({
        dataType: 'note',
        fieldName: 'note',
        selector: '.notes'
      });
      this.collapseLongCommitList();
      this.setViewType(view);

      // We are in the Merge Requests page so we need another edit form for Changes tab
      if (gl.utils.getPagePath(1) === 'merge_requests') {
        $('.note-edit-form').clone()
          .addClass('mr-note-edit-form').insertAfter('.note-edit-form');
      }
    }

    Notes.prototype.setViewType = function(view) {
      this.view = Cookies.get('diff_view') || view;
    };

    Notes.prototype.addBinding = function() {
      // Edit note link
      $(document).on("click", ".js-note-edit", this.showEditForm.bind(this));
      $(document).on("click", ".note-edit-cancel", this.cancelEdit);
      // Reopen and close actions for Issue/MR combined with note form submit
      $(document).on("click", ".js-comment-submit-button", this.postComment);
      $(document).on("click", ".js-comment-save-button", this.updateComment);
      $(document).on("keyup input", ".js-note-text", this.updateTargetButtons);
      // resolve a discussion
      $(document).on('click', '.js-comment-resolve-button', this.postComment);
      // remove a note (in general)
      $(document).on("click", ".js-note-delete", this.removeNote);
      // delete note attachment
      $(document).on("click", ".js-note-attachment-delete", this.removeAttachment);
      // reset main target form when clicking discard
      $(document).on("click", ".js-note-discard", this.resetMainTargetForm);
      // update the file name when an attachment is selected
      $(document).on("change", ".js-note-attachment-input", this.updateFormAttachment);
      // reply to diff/discussion notes
      $(document).on("click", ".js-discussion-reply-button", this.onReplyToDiscussionNote);
      // add diff note
      $(document).on("click", ".js-add-diff-note-button", this.onAddDiffNote);
      // hide diff note form
      $(document).on("click", ".js-close-discussion-note-form", this.cancelDiscussionForm);
      // toggle commit list
      $(document).on("click", '.system-note-commit-list-toggler', this.toggleCommitList);
      // fetch notes when tab becomes visible
      $(document).on("visibilitychange", this.visibilityChange);
      // when issue status changes, we need to refresh data
      $(document).on("issuable:change", this.refresh);
      // ajax:events that happen on Form when actions like Reopen, Close are performed on Issues and MRs.
      $(document).on("ajax:success", ".js-main-target-form", this.addNote);
      $(document).on("ajax:success", ".js-discussion-note-form", this.addDiscussionNote);
      $(document).on("ajax:success", ".js-main-target-form", this.resetMainTargetForm);
      $(document).on("ajax:complete", ".js-main-target-form", this.reenableTargetFormSubmitButton);
      // when a key is clicked on the notes
      return $(document).on("keydown", ".js-note-text", this.keydownNoteText);
    };

    Notes.prototype.cleanBinding = function() {
      $(document).off("click", ".js-note-edit");
      $(document).off("click", ".note-edit-cancel");
      $(document).off("click", ".js-note-delete");
      $(document).off("click", ".js-note-attachment-delete");
      $(document).off("click", ".js-discussion-reply-button");
      $(document).off("click", ".js-add-diff-note-button");
      $(document).off("visibilitychange");
      $(document).off("keyup input", ".js-note-text");
      $(document).off("click", ".js-note-target-reopen");
      $(document).off("click", ".js-note-target-close");
      $(document).off("click", ".js-note-discard");
      $(document).off("keydown", ".js-note-text");
      $(document).off('click', '.js-comment-resolve-button');
      $(document).off("click", '.system-note-commit-list-toggler');
      $(document).off("ajax:success", ".js-main-target-form");
      $(document).off("ajax:success", ".js-discussion-note-form");
      $(document).off("ajax:complete", ".js-main-target-form");
    };

    Notes.initCommentTypeToggle = function (form) {
      const dropdownTrigger = form.querySelector('.js-comment-type-dropdown .dropdown-toggle');
      const dropdownList = form.querySelector('.js-comment-type-dropdown .dropdown-menu');
      const noteTypeInput = form.querySelector('#note_type');
      const submitButton = form.querySelector('.js-comment-type-dropdown .js-comment-submit-button');
      const closeButton = form.querySelector('.js-note-target-close');
      const reopenButton = form.querySelector('.js-note-target-reopen');

      const commentTypeToggle = new CommentTypeToggle({
        dropdownTrigger,
        dropdownList,
        noteTypeInput,
        submitButton,
        closeButton,
        reopenButton,
      });

      commentTypeToggle.initDroplab();
    };

    Notes.prototype.keydownNoteText = function(e) {
      var $textarea, discussionNoteForm, editNote, myLastNote, myLastNoteEditBtn, newText, originalText;
      if (gl.utils.isMetaKey(e)) {
        return;
      }

      $textarea = $(e.target);
      // Edit previous note when UP arrow is hit
      switch (e.which) {
        case 38:
          if ($textarea.val() !== '') {
            return;
          }
          myLastNote = $("li.note[data-author-id='" + gon.current_user_id + "'][data-editable]:last");
          if (myLastNote.length) {
            myLastNoteEditBtn = myLastNote.find('.js-note-edit');
            return myLastNoteEditBtn.trigger('click', [true, myLastNote]);
          }
          break;
        // Cancel creating diff note or editing any note when ESCAPE is hit
        case 27:
          discussionNoteForm = $textarea.closest('.js-discussion-note-form');
          if (discussionNoteForm.length) {
            if ($textarea.val() !== '') {
              if (!confirm('Are you sure you want to cancel creating this comment?')) {
                return;
              }
            }
            this.removeDiscussionNoteForm(discussionNoteForm);
            return;
          }
          editNote = $textarea.closest('.note');
          if (editNote.length) {
            originalText = $textarea.closest('form').data('original-note');
            newText = $textarea.val();
            if (originalText !== newText) {
              if (!confirm('Are you sure you want to cancel editing this comment?')) {
                return;
              }
            }
            return this.removeNoteEditForm(editNote);
          }
      }
    };

    Notes.prototype.initRefresh = function() {
      clearInterval(Notes.interval);
      return Notes.interval = setInterval((function(_this) {
        return function() {
          return _this.refresh();
        };
      })(this), this.pollingInterval);
    };

    Notes.prototype.refresh = function() {
      if (!document.hidden) {
        return this.getContent();
      }
    };

    Notes.prototype.getContent = function() {
      if (this.refreshing) {
        return;
      }
      this.refreshing = true;
      return $.ajax({
        url: this.notes_url,
        headers: { "X-Last-Fetched-At": this.last_fetched_at },
        dataType: "json",
        success: (function(_this) {
          return function(data) {
            var notes;
            notes = data.notes;
            _this.last_fetched_at = data.last_fetched_at;
            _this.setPollingInterval(data.notes.length);
            return $.each(notes, function(i, note) {
              _this.renderNote(note);
            });
          };
        })(this)
      }).always((function(_this) {
        return function() {
          return _this.refreshing = false;
        };
      })(this));
    };

    /*
    Increase @pollingInterval up to 120 seconds on every function call,
    if `shouldReset` has a truthy value, 'null' or 'undefined' the variable
    will reset to @basePollingInterval.

    Note: this function is used to gradually increase the polling interval
    if there aren't new notes coming from the server
     */

    Notes.prototype.setPollingInterval = function(shouldReset) {
      var nthInterval;
      if (shouldReset == null) {
        shouldReset = true;
      }
      nthInterval = this.basePollingInterval * Math.pow(2, this.maxPollingSteps - 1);
      if (shouldReset) {
        this.pollingInterval = this.basePollingInterval;
      } else if (this.pollingInterval < nthInterval) {
        this.pollingInterval *= 2;
      }
      return this.initRefresh();
    };

    Notes.prototype.handleSlashCommands = function(noteEntity) {
      var votesBlock;
      if (noteEntity.commands_changes) {
        if ('merge' in noteEntity.commands_changes) {
          Notes.checkMergeRequestStatus();
        }

        if ('emoji_award' in noteEntity.commands_changes) {
          votesBlock = $('.js-awards-block').eq(0);
          gl.awardsHandler.addAwardToEmojiBar(votesBlock, noteEntity.commands_changes.emoji_award);
          return gl.awardsHandler.scrollToAwards();
        }
      }
    };

    Notes.prototype.setupNewNote = function($note) {
      // Update datetime format on the recent note
      gl.utils.localTimeAgo($note.find('.js-timeago'), false);
      this.collapseLongCommitList();
      this.taskList.init();
    };

    /*
    Render note in main comments area.

    Note: for rendering inline notes use renderDiscussionNote
     */

    Notes.prototype.renderNote = function(noteEntity, $form, $notesList = $('.main-notes-list')) {
      if (noteEntity.discussion_html != null) {
        return this.renderDiscussionNote(noteEntity, $form);
      }

      if (!noteEntity.valid) {
        if (noteEntity.errors.commands_only) {
          new Flash(noteEntity.errors.commands_only, 'notice', this.parentTimeline);
          this.refresh();
        }
        return;
      }

      const $note = $notesList.find(`#note_${noteEntity.id}`);
      if (Notes.isNewNote(noteEntity, this.note_ids)) {
        this.note_ids.push(noteEntity.id);

        const $newNote = Notes.animateAppendNote(noteEntity.html, $notesList);

        this.setupNewNote($newNote);
        this.refresh();
        return this.updateNotesCount(1);
      }
      // The server can send the same update multiple times so we need to make sure to only update once per actual update.
      else if (Notes.isUpdatedNote(noteEntity, $note)) {
        const isEditing = $note.hasClass('is-editing');
        const initialContent = normalizeNewlines(
          $note.find('.original-note-content').text().trim()
        );
        const $textarea = $note.find('.js-note-text');
        const currentContent = $textarea.val();
        // There can be CRLF vs LF mismatches if we don't sanitize and compare the same way
        const sanitizedNoteNote = normalizeNewlines(noteEntity.note);
        const isTextareaUntouched = currentContent === initialContent || currentContent === sanitizedNoteNote;

        if (isEditing && isTextareaUntouched) {
          $textarea.val(noteEntity.note);
          this.updatedNotesTrackingMap[noteEntity.id] = noteEntity;
        }
        else if (isEditing && !isTextareaUntouched) {
          this.putConflictEditWarningInPlace(noteEntity, $note);
          this.updatedNotesTrackingMap[noteEntity.id] = noteEntity;
        }
        else {
          const $updatedNote = Notes.animateUpdateNote(noteEntity.html, $note);
          this.setupNewNote($updatedNote);
        }
      }
    };

    Notes.prototype.isParallelView = function() {
      return Cookies.get('diff_view') === 'parallel';
    };

    /*
    Render note in discussion area.

    Note: for rendering inline notes use renderDiscussionNote
     */

    Notes.prototype.renderDiscussionNote = function(noteEntity, $form) {
      var discussionContainer, form, row, lineType, diffAvatarContainer;
      if (!Notes.isNewNote(noteEntity, this.note_ids)) {
        return;
      }
      this.note_ids.push(noteEntity.id);
      form = $form || $(".js-discussion-note-form[data-discussion-id='" + noteEntity.discussion_id + "']");
      row = form.closest("tr");
      lineType = this.isParallelView() ? form.find('#line_type').val() : 'old';
      diffAvatarContainer = row.prevAll('.line_holder').first().find('.js-avatar-container.' + lineType + '_line');
      // is this the first note of discussion?
      discussionContainer = $(`.notes[data-discussion-id="${noteEntity.discussion_id}"]`);
      if (!discussionContainer.length) {
        discussionContainer = form.closest('.discussion').find('.notes');
      }
      if (discussionContainer.length === 0) {
        if (noteEntity.diff_discussion_html) {
          var $discussion = $(noteEntity.diff_discussion_html).renderGFM();

          if (!this.isParallelView() || row.hasClass('js-temp-notes-holder')) {
            // insert the note and the reply button after the temp row
            row.after($discussion);
          } else {
            // Merge new discussion HTML in
            var $notes = $discussion.find('.notes[data-discussion-id="' + noteEntity.discussion_id + '"]');
            var contentContainerClass = '.' + $notes.closest('.notes_content')
              .attr('class')
              .split(' ')
              .join('.');

            row.find(contentContainerClass + ' .content').append($notes.closest('.content').children());
          }
        }
        // Init discussion on 'Discussion' page if it is merge request page
        const page = $('body').attr('data-page');
        if ((page && page.indexOf('projects:merge_request') === 0) || !noteEntity.diff_discussion_html) {
          Notes.animateAppendNote(noteEntity.discussion_html, $('.main-notes-list'));
        }
      } else {
        // append new note to all matching discussions
        Notes.animateAppendNote(noteEntity.html, discussionContainer);
      }

      if (typeof gl.diffNotesCompileComponents !== 'undefined' && noteEntity.discussion_resolvable) {
        gl.diffNotesCompileComponents();
        this.renderDiscussionAvatar(diffAvatarContainer, noteEntity);
      }

      gl.utils.localTimeAgo($('.js-timeago'), false);
      Notes.checkMergeRequestStatus();
      return this.updateNotesCount(1);
    };

    Notes.prototype.getLineHolder = function(changesDiscussionContainer) {
      return $(changesDiscussionContainer).closest('.notes_holder')
        .prevAll('.line_holder')
        .first()
        .get(0);
    };

    Notes.prototype.renderDiscussionAvatar = function(diffAvatarContainer, noteEntity) {
      var commentButton = diffAvatarContainer.find('.js-add-diff-note-button');
      var avatarHolder = diffAvatarContainer.find('.diff-comment-avatar-holders');

      if (!avatarHolder.length) {
        avatarHolder = document.createElement('diff-note-avatars');
        avatarHolder.setAttribute('discussion-id', noteEntity.discussion_id);

        diffAvatarContainer.append(avatarHolder);

        gl.diffNotesCompileComponents();
      }

      if (commentButton.length) {
        commentButton.remove();
      }
    };

    /*
    Called in response the main target form has been successfully submitted.

    Removes any errors.
    Resets text and preview.
    Resets buttons.
     */

    Notes.prototype.resetMainTargetForm = function(e) {
      var form;
      form = $(".js-main-target-form");
      // remove validation errors
      form.find(".js-errors").remove();
      // reset text and preview
      form.find(".js-md-write-button").click();
      form.find(".js-note-text").val("").trigger("input");
      form.find(".js-note-text").data("autosave").reset();

      var event = document.createEvent('Event');
      event.initEvent('autosize:update', true, false);
      form.find('.js-autosize')[0].dispatchEvent(event);

      this.updateTargetButtons(e);
    };

    Notes.prototype.reenableTargetFormSubmitButton = function() {
      var form;
      form = $(".js-main-target-form");
      return form.find(".js-note-text").trigger("input");
    };

    /*
    Shows the main form and does some setup on it.

    Sets some hidden fields in the form.
     */

    Notes.prototype.setupMainTargetNoteForm = function() {
      var form;
      // find the form
      form = $(".js-new-note-form");
      // Set a global clone of the form for later cloning
      this.formClone = form.clone();
      // show the form
      this.setupNoteForm(form);
      // fix classes
      form.removeClass("js-new-note-form");
      form.addClass("js-main-target-form");
      form.find("#note_line_code").remove();
      form.find("#note_position").remove();
      form.find("#note_type").val('');
      form.find("#in_reply_to_discussion_id").remove();
      form.find('.js-comment-resolve-button').closest('comment-and-resolve-btn').remove();
      this.parentTimeline = form.parents('.timeline');

      if (form.length) {
        Notes.initCommentTypeToggle(form.get(0));
      }
    };

    /*
    General note form setup.

    deactivates the submit button when text is empty
    hides the preview button when text is empty
    setup GFM auto complete
    show the form
     */

    Notes.prototype.setupNoteForm = function(form) {
      var textarea, key;
      new gl.GLForm(form);
      textarea = form.find(".js-note-text");
      key = [
        "Note",
        form.find("#note_noteable_type").val(),
        form.find("#note_noteable_id").val(),
        form.find("#note_commit_id").val(),
        form.find("#note_type").val(),
        form.find("#in_reply_to_discussion_id").val(),

        // LegacyDiffNote
        form.find("#note_line_code").val(),

        // DiffNote
        form.find("#note_position").val()
      ];
      return new Autosave(textarea, key);
    };

    /*
    Called in response to the new note form being submitted

    Adds new note to list.
     */

    Notes.prototype.addNote = function($form, note) {
      return this.renderNote(note);
    };

    Notes.prototype.addNoteError = ($form) => {
      let formParentTimeline;
      if ($form.hasClass('js-main-target-form')) {
        formParentTimeline = $form.parents('.timeline');
      } else if ($form.hasClass('js-discussion-note-form')) {
        formParentTimeline = $form.closest('.discussion-notes').find('.notes');
      }
      return new Flash('Your comment could not be submitted! Please check your network connection and try again.', 'alert', formParentTimeline);
    };

    Notes.prototype.updateNoteError = $parentTimeline => new Flash('Your comment could not be updated! Please check your network connection and try again.');

    /*
    Called in response to the new note form being submitted

    Adds new note to list.
     */

    Notes.prototype.addDiscussionNote = function($form, note, isNewDiffComment) {
      if ($form.attr('data-resolve-all') != null) {
        var projectPath = $form.data('project-path');
        var discussionId = $form.data('discussion-id');
        var mergeRequestId = $form.data('noteable-iid');

        if (ResolveService != null) {
          ResolveService.toggleResolveForDiscussion(mergeRequestId, discussionId);
        }
      }

      this.renderNote(note, $form);
      // cleanup after successfully creating a diff/discussion note
      if (isNewDiffComment) {
        this.removeDiscussionNoteForm($form);
      }
    };

    /*
    Called in response to the edit note form being submitted

    Updates the current note field.
     */

    Notes.prototype.updateNote = function(noteEntity, $targetNote) {
      var $noteEntityEl, $note_li;
      // Convert returned HTML to a jQuery object so we can modify it further
      $noteEntityEl = $(noteEntity.html);
      $noteEntityEl.addClass('fade-in-full');
      this.revertNoteEditForm($targetNote);
      gl.utils.localTimeAgo($('.js-timeago', $noteEntityEl));
      $noteEntityEl.renderGFM();
      $noteEntityEl.find('.js-task-list-container').taskList('enable');
      // Find the note's `li` element by ID and replace it with the updated HTML
      $note_li = $('.note-row-' + noteEntity.id);

      $note_li.replaceWith($noteEntityEl);

      if (typeof gl.diffNotesCompileComponents !== 'undefined') {
        gl.diffNotesCompileComponents();
      }
    };

    Notes.prototype.checkContentToAllowEditing = function($el) {
      var initialContent = $el.find('.original-note-content').text().trim();
      var currentContent = $el.find('.js-note-text').val();
      var isAllowed = true;

      if (currentContent === initialContent) {
        this.removeNoteEditForm($el);
      }
      else {
        var $buttons = $el.find('.note-form-actions');
        var isWidgetVisible = gl.utils.isInViewport($el.get(0));

        if (!isWidgetVisible) {
          gl.utils.scrollToElement($el);
        }

        $el.find('.js-finish-edit-warning').show();
        isAllowed = false;
      }

      return isAllowed;
    };

    /*
    Called in response to clicking the edit note link

    Replaces the note text with the note edit form
    Adds a data attribute to the form with the original content of the note for cancellations
    */
    Notes.prototype.showEditForm = function(e, scrollTo, myLastNote) {
      e.preventDefault();

      var $target = $(e.target);
      var $editForm = $(this.getEditFormSelector($target));
      var $note = $target.closest('.note');
      var $currentlyEditing = $('.note.is-editing:visible');

      if ($currentlyEditing.length) {
        var isEditAllowed = this.checkContentToAllowEditing($currentlyEditing);

        if (!isEditAllowed) {
          return;
        }
      }

      $note.find('.js-note-attachment-delete').show();
      $editForm.addClass('current-note-edit-form');
      $note.addClass('is-editing');
      this.putEditFormInPlace($target);
    };

    /*
    Called in response to clicking the edit note link

    Hides edit form and restores the original note text to the editor textarea.
     */

    Notes.prototype.cancelEdit = function(e) {
      e.preventDefault();
      const $target = $(e.target);
      const $note = $target.closest('.note');
      const noteId = $note.attr('data-note-id');

      this.revertNoteEditForm($target);

      if (this.updatedNotesTrackingMap[noteId]) {
        const $newNote = $(this.updatedNotesTrackingMap[noteId].html);
        $note.replaceWith($newNote);
        this.setupNewNote($newNote);
        this.updatedNotesTrackingMap[noteId] = null;
      }
      else {
        $note.find('.js-finish-edit-warning').hide();
        this.removeNoteEditForm($note);
      }
    };

    Notes.prototype.revertNoteEditForm = function($target) {
      $target = $target || $('.note.is-editing:visible');
      var selector = this.getEditFormSelector($target);
      var $editForm = $(selector);

      $editForm.insertBefore('.notes-form');
      $editForm.find('.js-comment-save-button').enable();
      $editForm.find('.js-finish-edit-warning').hide();
    };

    Notes.prototype.getEditFormSelector = function($el) {
      var selector = '.note-edit-form:not(.mr-note-edit-form)';

      if ($el.parents('#diffs').length) {
        selector = '.note-edit-form.mr-note-edit-form';
      }

      return selector;
    };

    Notes.prototype.removeNoteEditForm = function($note) {
      var form = $note.find('.current-note-edit-form');
      $note.removeClass('is-editing');
      form.removeClass('current-note-edit-form');
      form.find('.js-finish-edit-warning').hide();
      // Replace markdown textarea text with original note text.
      return form.find('.js-note-text').val(form.find('form.edit-note').data('original-note'));
    };

    /*
    Called in response to deleting a note of any kind.

    Removes the actual note from view.
    Removes the whole discussion if the last note is being removed.
     */

    Notes.prototype.removeNote = function(e) {
      var noteElId, noteId, dataNoteId, $note, lineHolder;
      $note = $(e.currentTarget).closest('.note');
      noteElId = $note.attr('id');
      noteId = $note.attr('data-note-id');
      lineHolder = $(e.currentTarget).closest('.notes[data-discussion-id]')
        .closest('.notes_holder')
        .prev('.line_holder');
      $(".note[id='" + noteElId + "']").each((function(_this) {
        // A same note appears in the "Discussion" and in the "Changes" tab, we have
        // to remove all. Using $(".note[id='noteId']") ensure we get all the notes,
        // where $("#noteId") would return only one.
        return function(i, el) {
          var $note, $notes;
          $note = $(el);
          $notes = $note.closest(".discussion-notes");

          if (typeof gl.diffNotesCompileComponents !== 'undefined') {
            if (gl.diffNoteApps[noteElId]) {
              gl.diffNoteApps[noteElId].$destroy();
            }
          }

          $note.remove();

          // check if this is the last note for this line
          if ($notes.find(".note").length === 0) {
            var notesTr = $notes.closest("tr");

            // "Discussions" tab
            $notes.closest(".timeline-entry").remove();

            // The notes tr can contain multiple lists of notes, like on the parallel diff
            if (notesTr.find('.discussion-notes').length > 1) {
              $notes.remove();
            } else {
              notesTr.remove();
            }
          }
        };
      })(this));

      Notes.checkMergeRequestStatus();
      return this.updateNotesCount(-1);
    };

    /*
    Called in response to clicking the delete attachment link

    Removes the attachment wrapper view, including image tag if it exists
    Resets the note editing form
     */

    Notes.prototype.removeAttachment = function() {
      const $note = $(this).closest(".note");
      $note.find(".note-attachment").remove();
      $note.find(".note-body > .note-text").show();
      $note.find(".note-header").show();
      return $note.find(".current-note-edit-form").remove();
    };

    /*
    Called when clicking on the "reply" button for a diff line.

    Shows the note form below the notes.
     */

    Notes.prototype.onReplyToDiscussionNote = function(e) {
      this.replyToDiscussionNote(e.target);
    };

    Notes.prototype.replyToDiscussionNote = function(target) {
      var form, replyLink;
      form = this.cleanForm(this.formClone.clone());
      replyLink = $(target).closest(".js-discussion-reply-button");
      // insert the form after the button
      replyLink
        .closest('.discussion-reply-holder')
        .hide()
        .after(form);
      // show the form
      return this.setupDiscussionNoteForm(replyLink, form);
    };

    /*
    Shows the diff or discussion form and does some setup on it.

    Sets some hidden fields in the form.

    Note: dataHolder must have the "discussionId" and "lineCode" data attributes set.
     */

    Notes.prototype.setupDiscussionNoteForm = function(dataHolder, form) {
      // setup note target
      var discussionID = dataHolder.data("discussionId");

      if (discussionID) {
        form.attr("data-discussion-id", discussionID);
        form.find("#in_reply_to_discussion_id").val(discussionID);
      }

      form.attr("data-line-code", dataHolder.data("lineCode"));
      form.find("#line_type").val(dataHolder.data("lineType"));

      form.find("#note_noteable_type").val(dataHolder.data("noteableType"));
      form.find("#note_noteable_id").val(dataHolder.data("noteableId"));
      form.find("#note_commit_id").val(dataHolder.data("commitId"));
      form.find("#note_type").val(dataHolder.data("noteType"));

      // LegacyDiffNote
      form.find("#note_line_code").val(dataHolder.data("lineCode"));

      // DiffNote
      form.find("#note_position").val(dataHolder.attr("data-position"));

      form.find('.js-note-discard').show().removeClass('js-note-discard').addClass('js-close-discussion-note-form').text(form.find('.js-close-discussion-note-form').data('cancel-text'));
      form.find('.js-note-target-close').remove();
      form.find('.js-note-new-discussion').remove();
      this.setupNoteForm(form);

      form
        .removeClass('js-main-target-form')
        .addClass("discussion-form js-discussion-note-form");

      if (typeof gl.diffNotesCompileComponents !== 'undefined') {
        var $commentBtn = form.find('comment-and-resolve-btn');
        $commentBtn.attr(':discussion-id', `'${discussionID}'`);

        gl.diffNotesCompileComponents();
      }

      form.find(".js-note-text").focus();
      form
        .find('.js-comment-resolve-button')
        .attr('data-discussion-id', discussionID);
    };

    /*
    Called when clicking on the "add a comment" button on the side of a diff line.

    Inserts a temporary row for the form below the line.
    Sets up the form and shows it.
     */

    Notes.prototype.onAddDiffNote = function(e) {
      e.preventDefault();
      const link = e.currentTarget || e.target;
      const $link = $(link);
      const showReplyInput = !$link.hasClass('js-diff-comment-avatar');
      this.toggleDiffNote({
        target: $link,
        lineType: link.dataset.lineType,
        showReplyInput
      });
    };

    Notes.prototype.toggleDiffNote = function({
      target,
      lineType,
      forceShow,
      showReplyInput = false,
    }) {
      var $link, addForm, hasNotes, newForm, noteForm, replyButton, row, rowCssToAdd, targetContent, isDiffCommentAvatar;
      $link = $(target);
      row = $link.closest("tr");
      const nextRow = row.next();
      let targetRow = row;
      if (nextRow.is('.notes_holder')) {
        targetRow = nextRow;
      }

      hasNotes = targetRow.is(".notes_holder");
      addForm = false;
      let lineTypeSelector = '';
      rowCssToAdd = "<tr class=\"notes_holder js-temp-notes-holder\"><td class=\"notes_line\" colspan=\"2\"></td><td class=\"notes_content\"><div class=\"content\"></div></td></tr>";
      // In parallel view, look inside the correct left/right pane
      if (this.isParallelView()) {
        lineTypeSelector = `.${lineType}`;
        rowCssToAdd = "<tr class=\"notes_holder js-temp-notes-holder\"><td class=\"notes_line old\"></td><td class=\"notes_content parallel old\"><div class=\"content\"></div></td><td class=\"notes_line new\"></td><td class=\"notes_content parallel new\"><div class=\"content\"></div></td></tr>";
      }
      const notesContentSelector = `.notes_content${lineTypeSelector} .content`;
      let notesContent = targetRow.find(notesContentSelector);

      if (hasNotes && showReplyInput) {
        targetRow.show();
        notesContent = targetRow.find(notesContentSelector);
        if (notesContent.length) {
          notesContent.show();
          replyButton = notesContent.find(".js-discussion-reply-button:visible");
          if (replyButton.length) {
            this.replyToDiscussionNote(replyButton[0]);
          } else {
            // In parallel view, the form may not be present in one of the panes
            noteForm = notesContent.find(".js-discussion-note-form");
            if (noteForm.length === 0) {
              addForm = true;
            }
          }
        }
      } else if (showReplyInput) {
        // add a notes row and insert the form
        row.after(rowCssToAdd);
        targetRow = row.next();
        notesContent = targetRow.find(notesContentSelector);
        addForm = true;
      } else {
        const isCurrentlyShown = targetRow.find('.content:not(:empty)').is(':visible');
        const isForced = forceShow === true || forceShow === false;
        const showNow = forceShow === true || (!isCurrentlyShown && !isForced);

        targetRow.toggle(showNow);
        notesContent.toggle(showNow);
      }

      if (addForm) {
        newForm = this.cleanForm(this.formClone.clone());
        newForm.appendTo(notesContent);
        // show the form
        return this.setupDiscussionNoteForm($link, newForm);
      }
    };

    /*
    Called in response to "cancel" on a diff note form.

    Shows the reply button again.
    Removes the form and if necessary it's temporary row.
     */

    Notes.prototype.removeDiscussionNoteForm = function(form) {
      var glForm, row;
      row = form.closest("tr");
      glForm = form.data('gl-form');
      glForm.destroy();
      form.find(".js-note-text").data("autosave").reset();
      // show the reply button (will only work for replies)
      form
        .prev('.discussion-reply-holder')
        .show();
      if (row.is(".js-temp-notes-holder")) {
        // remove temporary row for diff lines
        return row.remove();
      } else {
        // only remove the form
        return form.remove();
      }
    };

    Notes.prototype.cancelDiscussionForm = function(e) {
      var form;
      e.preventDefault();
      form = $(e.target).closest(".js-discussion-note-form");
      return this.removeDiscussionNoteForm(form);
    };

    /*
    Called after an attachment file has been selected.

    Updates the file name for the selected attachment.
     */

    Notes.prototype.updateFormAttachment = function() {
      var filename, form;
      form = $(this).closest("form");
      // get only the basename
      filename = $(this).val().replace(/^.*[\\\/]/, "");
      return form.find(".js-attachment-filename").text(filename);
    };

    /*
    Called when the tab visibility changes
     */

    Notes.prototype.visibilityChange = function() {
      return this.refresh();
    };

    Notes.prototype.updateTargetButtons = function(e) {
      var closebtn, closetext, discardbtn, form, reopenbtn, reopentext, textarea;
      textarea = $(e.target);
      form = textarea.parents('form');
      reopenbtn = form.find('.js-note-target-reopen');
      closebtn = form.find('.js-note-target-close');
      discardbtn = form.find('.js-note-discard');

      if (textarea.val().trim().length > 0) {
        reopentext = reopenbtn.attr('data-alternative-text');
        closetext = closebtn.attr('data-alternative-text');
        if (reopenbtn.text() !== reopentext) {
          reopenbtn.text(reopentext);
        }
        if (closebtn.text() !== closetext) {
          closebtn.text(closetext);
        }
        if (reopenbtn.is(':not(.btn-comment-and-reopen)')) {
          reopenbtn.addClass('btn-comment-and-reopen');
        }
        if (closebtn.is(':not(.btn-comment-and-close)')) {
          closebtn.addClass('btn-comment-and-close');
        }
        if (discardbtn.is(':hidden')) {
          return discardbtn.show();
        }
      } else {
        reopentext = reopenbtn.data('original-text');
        closetext = closebtn.data('original-text');
        if (reopenbtn.text() !== reopentext) {
          reopenbtn.text(reopentext);
        }
        if (closebtn.text() !== closetext) {
          closebtn.text(closetext);
        }
        if (reopenbtn.is('.btn-comment-and-reopen')) {
          reopenbtn.removeClass('btn-comment-and-reopen');
        }
        if (closebtn.is('.btn-comment-and-close')) {
          closebtn.removeClass('btn-comment-and-close');
        }
        if (discardbtn.is(':visible')) {
          return discardbtn.hide();
        }
      }
    };

    Notes.prototype.putEditFormInPlace = function($el) {
      var $editForm = $(this.getEditFormSelector($el));
      var $note = $el.closest('.note');

      $editForm.insertAfter($note.find('.note-text'));

      var $originalContentEl = $note.find('.original-note-content');
      var originalContent = $originalContentEl.text().trim();
      var postUrl = $originalContentEl.data('post-url');
      var targetId = $originalContentEl.data('target-id');
      var targetType = $originalContentEl.data('target-type');

      new gl.GLForm($editForm.find('form'));

      $editForm.find('form')
        .attr('action', postUrl)
        .attr('data-remote', 'true');
      $editForm.find('.js-form-target-id').val(targetId);
      $editForm.find('.js-form-target-type').val(targetType);
      $editForm.find('.js-note-text').focus().val(originalContent);
      $editForm.find('.js-md-write-button').trigger('click');
      $editForm.find('.referenced-users').hide();
    };

    Notes.prototype.putConflictEditWarningInPlace = function(noteEntity, $note) {
      if ($note.find('.js-conflict-edit-warning').length === 0) {
        const $alert = $(`<div class="js-conflict-edit-warning alert alert-danger">
          This comment has changed since you started editing, please review the
          <a href="#note_${noteEntity.id}" target="_blank" rel="noopener noreferrer">
            updated comment
          </a>
          to ensure information is not lost
        </div>`);
        $alert.insertAfter($note.find('.note-text'));
      }
    };

    Notes.prototype.updateNotesCount = function(updateCount) {
      return this.notesCountBadge.text(parseInt(this.notesCountBadge.text(), 10) + updateCount);
    };

    Notes.prototype.toggleCommitList = function(e) {
      const $element = $(e.currentTarget);
      const $closestSystemCommitList = $element.siblings('.system-note-commit-list');

      $element.find('.fa').toggleClass('fa-angle-down').toggleClass('fa-angle-up');
      $closestSystemCommitList.toggleClass('hide-shade');
    };

    /**
    Scans system notes with `ul` elements in system note body
    then collapse long commit list pushed by user to make it less
    intrusive.
     */
    Notes.prototype.collapseLongCommitList = function() {
      const systemNotes = $('#notes-list').find('li.system-note').has('ul');

      $.each(systemNotes, function(index, systemNote) {
        const $systemNote = $(systemNote);
        const headerMessage = $systemNote.find('.note-text').find('p:first').text().replace(':', '');

        $systemNote.find('.note-header .system-note-message').html(headerMessage);

        if ($systemNote.find('li').length > MAX_VISIBLE_COMMIT_LIST_COUNT) {
          $systemNote.find('.note-text').addClass('system-note-commit-list');
          $systemNote.find('.system-note-commit-list-toggler').show();
        } else {
          $systemNote.find('.note-text').addClass('system-note-commit-list hide-shade');
        }
      });
    };

    Notes.prototype.cleanForm = function($form) {
      // Remove JS classes that are not needed here
      $form
        .find('.js-comment-type-dropdown')
        .removeClass('btn-group');

      // Remove dropdown
      $form
        .find('.dropdown-menu')
        .remove();

      return $form;
    };

    /**
     * Check if note does not exists on page
     */
    Notes.isNewNote = function(noteEntity, noteIds) {
      return $.inArray(noteEntity.id, noteIds) === -1;
    };

    /**
     * Check if $note already contains the `noteEntity` content
     */
    Notes.isUpdatedNote = function(noteEntity, $note) {
      // There can be CRLF vs LF mismatches if we don't sanitize and compare the same way
      const sanitizedNoteEntityText = normalizeNewlines(noteEntity.note.trim());
      const currentNoteText = normalizeNewlines(
        $note.find('.original-note-content').first().text().trim()
      );
      return sanitizedNoteEntityText !== currentNoteText;
    };

    Notes.checkMergeRequestStatus = function() {
      if (gl.utils.getPagePath(1) === 'merge_requests') {
        gl.mrWidget.checkStatus();
      }
    };

    Notes.animateAppendNote = function(noteHTML, $notesList) {
      const $note = window.$(noteHTML);

      $note.addClass('fade-in-full').renderGFM();
      $notesList.append($note);
      return $note;
    };

    Notes.animateUpdateNote = function(noteHtml, $note) {
      const $updatedNote = $(noteHtml);

      $updatedNote.addClass('fade-in').renderGFM();
      $note.replaceWith($updatedNote);
      return $updatedNote;
    };

    /**
     * Get data from Form attributes to use for saving/submitting comment.
     */
    Notes.prototype.getFormData = function($form) {
      return {
        formData: $form.serialize(),
        formContent: $form.find('.js-note-text').val(),
        formAction: $form.attr('action'),
      };
    };

    /**
     * Identify if comment has any slash commands
     */
    Notes.prototype.hasSlashCommands = function(formContent) {
      return REGEX_SLASH_COMMANDS.test(formContent);
    };

    /**
     * Remove slash commands and leave comment with pure message
     */
    Notes.prototype.stripSlashCommands = function(formContent) {
      return formContent.replace(REGEX_SLASH_COMMANDS, '').trim();
    };

    /**
     * Create placeholder note DOM element populated with comment body
     * that we will show while comment is being posted.
     * Once comment is _actually_ posted on server, we will have final element
     * in response that we will show in place of this temporary element.
     */
    Notes.prototype.createPlaceholderNote = function({ formContent, uniqueId, isDiscussionNote, currentUsername, currentUserFullname }) {
      const discussionClass = isDiscussionNote ? 'discussion' : '';
      const escapedFormContent = _.escape(formContent);
      const $tempNote = $(
        `<li id="${uniqueId}" class="note being-posted fade-in-half timeline-entry">
           <div class="timeline-entry-inner">
              <div class="timeline-icon">
                 <a href="/${currentUsername}"><span class="dummy-avatar"></span></a>
              </div>
              <div class="timeline-content ${discussionClass}">
                 <div class="note-header">
                    <div class="note-header-info">
                       <a href="/${currentUsername}">
                         <span class="hidden-xs">${currentUserFullname}</span>
                         <span class="note-headline-light">@${currentUsername}</span>
                       </a>
                    </div>
                 </div>
                 <div class="note-body">
                   <div class="note-text">
                     <p>${escapedFormContent}</p>
                   </div>
                 </div>
              </div>
           </div>
        </li>`
      );

      return $tempNote;
    };

    /**
     * This method does following tasks step-by-step whenever a new comment
     * is submitted by user (both main thread comments as well as discussion comments).
     *
     * 1) Get Form metadata
     * 2) Identify comment type; a) Main thread b) Discussion thread c) Discussion resolve
     * 3) Build temporary placeholder element (using `createPlaceholderNote`)
     * 4) Show placeholder note on UI
     * 5) Perform network request to submit the note using `gl.utils.ajaxPost`
     *    a) If request is successfully completed
     *        1. Remove placeholder element
     *        2. Show submitted Note element
     *        3. Perform post-submit errands
     *           a. Mark discussion as resolved if comment submission was for resolve.
     *           b. Reset comment form to original state.
     *    b) If request failed
     *        1. Remove placeholder element
     *        2. Show error Flash message about failure
     */
    Notes.prototype.postComment = function(e) {
      e.preventDefault();

      // Get Form metadata
      const $submitBtn = $(e.target);
      let $form = $submitBtn.parents('form');
      const $closeBtn = $form.find('.js-note-target-close');
      const isDiscussionNote = $submitBtn.parent().find('li.droplab-item-selected').attr('id') === 'discussion';
      const isMainForm = $form.hasClass('js-main-target-form');
      const isDiscussionForm = $form.hasClass('js-discussion-note-form');
      const isDiscussionResolve = $submitBtn.hasClass('js-comment-resolve-button');
      const { formData, formContent, formAction } = this.getFormData($form);
      const uniqueId = _.uniqueId('tempNote_');
      let $notesContainer;
      let tempFormContent;

      // Get reference to notes container based on type of comment
      if (isDiscussionForm) {
        $notesContainer = $form.parent('.discussion-notes').find('.notes');
      } else if (isMainForm) {
        $notesContainer = $('ul.main-notes-list');
      }

      // If comment is to resolve discussion, disable submit buttons while
      // comment posting is finished.
      if (isDiscussionResolve) {
        $submitBtn.disable();
        $form.find('.js-comment-submit-button').disable();
      }

      tempFormContent = formContent;
      if (this.hasSlashCommands(formContent)) {
        tempFormContent = this.stripSlashCommands(formContent);
      }

      if (tempFormContent) {
        // Show placeholder note
        $notesContainer.append(this.createPlaceholderNote({
          formContent: tempFormContent,
          uniqueId,
          isDiscussionNote,
          currentUsername: gon.current_username,
          currentUserFullname: gon.current_user_fullname,
        }));
      }

      // Clear the form textarea
      if ($notesContainer.length) {
        if (isMainForm) {
          this.resetMainTargetForm(e);
        } else if (isDiscussionForm) {
          this.removeDiscussionNoteForm($form);
        }
      }

      /* eslint-disable promise/catch-or-return */
      // Make request to submit comment on server
      gl.utils.ajaxPost(formAction, formData)
        .then((note) => {
          // Submission successful! remove placeholder
          $notesContainer.find(`#${uniqueId}`).remove();

          // Check if this was discussion comment
          if (isDiscussionForm) {
            // Remove flash-container
            $notesContainer.find('.flash-container').remove();

            // If comment intends to resolve discussion, do the same.
            if (isDiscussionResolve) {
              $form
                .attr('data-discussion-id', $submitBtn.data('discussion-id'))
                .attr('data-resolve-all', 'true')
                .attr('data-project-path', $submitBtn.data('project-path'));
            }

            // Show final note element on UI
            this.addDiscussionNote($form, note, $notesContainer.length === 0);

            // append flash-container to the Notes list
            if ($notesContainer.length) {
              $notesContainer.append('<div class="flash-container" style="display: none;"></div>');
            }
          } else if (isMainForm) { // Check if this was main thread comment
            // Show final note element on UI and perform form and action buttons cleanup
            this.addNote($form, note);
            this.reenableTargetFormSubmitButton(e);
          }

          if (note.commands_changes) {
            this.handleSlashCommands(note);
          }

          $form.trigger('ajax:success', [note]);
        }).fail(() => {
          // Submission failed, remove placeholder note and show Flash error message
          $notesContainer.find(`#${uniqueId}`).remove();

          // Show form again on UI on failure
          if (isDiscussionForm && $notesContainer.length) {
            const replyButton = $notesContainer.parent().find('.js-discussion-reply-button');
            this.replyToDiscussionNote(replyButton[0]);
            $form = $notesContainer.parent().find('form');
          }

          $form.find('.js-note-text').val(formContent);
          this.reenableTargetFormSubmitButton(e);
          this.addNoteError($form);
        });

      return $closeBtn.text($closeBtn.data('original-text'));
    };

    /**
     * This method does following tasks step-by-step whenever an existing comment
     * is updated by user (both main thread comments as well as discussion comments).
     *
     * 1) Get Form metadata
     * 2) Update note element with new content
     * 3) Perform network request to submit the updated note using `gl.utils.ajaxPost`
     *    a) If request is successfully completed
     *        1. Show submitted Note element
     *    b) If request failed
     *        1. Revert Note element to original content
     *        2. Show error Flash message about failure
     */
    Notes.prototype.updateComment = function(e) {
      e.preventDefault();

      // Get Form metadata
      const $submitBtn = $(e.target);
      const $form = $submitBtn.parents('form');
      const $closeBtn = $form.find('.js-note-target-close');
      const $editingNote = $form.parents('.note.is-editing');
      const $noteBody = $editingNote.find('.js-task-list-container');
      const $noteBodyText = $noteBody.find('.note-text');
      const { formData, formContent, formAction } = this.getFormData($form);

      // Cache original comment content
      const cachedNoteBodyText = $noteBodyText.html();

      // Show updated comment content temporarily
      $noteBodyText.html(_.escape(formContent));
      $editingNote.removeClass('is-editing fade-in-full').addClass('being-posted fade-in-half');
      $editingNote.find('.note-headline-meta a').html('<i class="fa fa-spinner fa-spin" aria-label="Comment is being updated" aria-hidden="true"></i>');

      /* eslint-disable promise/catch-or-return */
      // Make request to update comment on server
      gl.utils.ajaxPost(formAction, formData)
        .then((note) => {
          // Submission successful! render final note element
          this.updateNote(note, $editingNote);
        })
        .fail(() => {
          // Submission failed, revert back to original note
          $noteBodyText.html(_.escape(cachedNoteBodyText));
          $editingNote.removeClass('being-posted fade-in');
          $editingNote.find('.fa.fa-spinner').remove();

          // Show Flash message about failure
          this.updateNoteError();
        });

      return $closeBtn.text($closeBtn.data('original-text'));
    };

    return Notes;
  })();
}).call(window);
