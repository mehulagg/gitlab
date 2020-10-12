<script>
import { mapGetters, mapState } from 'vuex';
import draftCommentsMixin from '~/diffs/mixins/draft_comments';
import DraftNote from '~/batch_comments/components/draft_note.vue';
import parallelDiffTableRow from './parallel_diff_table_row.vue';
import parallelDiffCommentRow from './parallel_diff_comment_row.vue';
import DiffExpansionCell from './diff_expansion_cell.vue';
import { getCommentedLines } from '~/notes/components/multiline_comment_utils';

export default {
  components: {
    DiffExpansionCell,
    parallelDiffTableRow,
    parallelDiffCommentRow,
    DraftNote,
  },
  mixins: [draftCommentsMixin],
  props: {
    diffFile: {
      type: Object,
      required: true,
    },
    diffLines: {
      type: Array,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapGetters('diffs', ['commitId']),
    ...mapState({
      selectedCommentPosition: ({ notes }) => notes.selectedCommentPosition,
      selectedCommentPositionHover: ({ notes }) => notes.selectedCommentPositionHover,
    }),
    diffLinesLength() {
      return this.diffLines.length;
    },
    commentedLines() {
      return getCommentedLines(
        this.selectedCommentPosition || this.selectedCommentPositionHover,
        this.diffLines,
      );
    },
  },
  userColorScheme: window.gon.user_color_scheme,
};
</script>

<template>
  <table
    :class="$options.userColorScheme"
    :data-commit-id="commitId"
    class="code diff-wrap-lines js-syntax-highlight text-file"
  >
    <colgroup>
      <col style="width: 50px;" />
      <col style="width: 8px;" />
      <col />
      <col style="width: 50px;" />
      <col style="width: 8px;" />
      <col />
    </colgroup>
    <tbody>
      <template v-for="(line, index) in diffLines">
        <tr
          v-if="line.isMatchLineLeft || line.isMatchLineRight"
          :key="`expand-${index}`"
          class="line_expansion match"
        >
          <td colspan="6" class="text-center gl-font-regular">
            <diff-expansion-cell
              :file-hash="diffFile.file_hash"
              :context-lines-path="diffFile.context_lines_path"
              :line="line.left"
              :is-top="index === 0"
              :is-bottom="index + 1 === diffLinesLength"
            />
          </td>
        </tr>
        <parallel-diff-table-row
          :key="line.line_code"
          :file-hash="diffFile.file_hash"
          :file-path="diffFile.file_path"
          :line="line"
          :is-bottom="index + 1 === diffLinesLength"
          :is-commented="index >= commentedLines.startLine && index <= commentedLines.endLine"
        />
        <parallel-diff-comment-row
          :key="`dcr-${line.line_code || index}`"
          :line="line"
          :diff-file-hash="diffFile.file_hash"
          :line-index="index"
          :help-page-path="helpPagePath"
          :has-draft-left="hasParallelDraftLeft(diffFile.file_hash, line) || false"
          :has-draft-right="hasParallelDraftRight(diffFile.file_hash, line) || false"
        />
        <tr
          v-if="shouldRenderParallelDraftRow(diffFile.file_hash, line)"
          :key="`drafts-${index}`"
          :class="line.draftRowClasses"
          class="notes_holder"
        >
          <td class="notes_line old"></td>
          <td class="notes-content parallel old" colspan="2">
            <div v-if="line.leftDraft.isDraft" class="content">
              <draft-note :draft="line.leftDraft" :line="line.left" />
            </div>
          </td>
          <td class="notes_line new"></td>
          <td class="notes-content parallel new" colspan="2">
            <div v-if="line.rightDraft.isDraft" class="content">
              <draft-note :draft="line.rightDraft" :line="line.right" />
            </div>
          </td>
        </tr>
      </template>
    </tbody>
  </table>
</template>
