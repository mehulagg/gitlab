<script>
/* eslint-disable vue/no-v-html */
import { GlTooltipDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import {
  PARALLEL_DIFF_VIEW_TYPE,
  CONFLICT_MARKER_THEIR,
  CONFLICT_OUR,
  CONFLICT_THEIR,
  CONFLICT_MARKER,
} from '../constants';
import {
  getInteropInlineAttributes,
  getInteropOldSideAttributes,
  getInteropNewSideAttributes,
} from '../utils/interoperability';
import * as utils from './diff_row_utils';

export default {
  DiffGutterAvatars: () => import('./diff_gutter_avatars.vue'),
  CodeQualityGutterIcon: () => import('ee_component/diffs/components/code_quality_gutter_icon.vue'),
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    fileHash: {
      type: String,
      required: true,
    },
    filePath: {
      type: String,
      required: true,
    },
    line: {
      type: Object,
      required: true,
    },
    isCommented: {
      type: Boolean,
      required: false,
      default: false,
    },
    inline: {
      type: Boolean,
      required: false,
      default: false,
    },
    index: {
      type: Number,
      required: true,
    },
    isLoggedIn: {
      type: Boolean,
      required: true,
    },
    isHighlighted: {
      type: Boolean,
      required: true,
    },
    fileLineCoverage: {
      type: Function,
      required: true,
    },
  },
  classNameMap(props) {
    return {
      [PARALLEL_DIFF_VIEW_TYPE]: !props.inline,
      commented: props.isCommented,
    };
  },
  parallelViewLeftLineType(props) {
    return utils.parallelViewLeftLineType(props.line, props.isHighlighted || props.isCommented);
  },
  coverageStateLeft(props) {
    if (!props.inline || !props.line.left) return {};
    return props.fileLineCoverage(props.filePath, props.line.left.new_line);
  },
  coverageStateRight(props) {
    if (!props.line.right) return {};
    return props.fileLineCoverage(props.filePath, props.line.right.new_line);
  },
  showCodequalityLeft(props) {
    return (
      window.gon?.features?.codequalityMrDiffAnnotations &&
      props.inline &&
      props.line.left?.codequality?.length > 0
    );
  },
  showCodequalityRight(props) {
    return (
      window.gon?.features?.codequalityMrDiffAnnotations &&
      !props.inline &&
      props.line.right?.codequality?.length > 0
    );
  },
  classNameMapCellLeft(props) {
    return utils.classNameMapCell({
      line: props.line.left,
      hll: props.isHighlighted || props.isCommented,
      isLoggedIn: props.isLoggedIn,
    });
  },
  classNameMapCellRight(props) {
    return utils.classNameMapCell({
      line: props.line.right,
      hll: props.isHighlighted || props.isCommented,
      isLoggedIn: props.isLoggedIn,
    });
  },
  shouldRenderCommentButton(props) {
    return props.isLoggedIn && !props.line.isContextLineLeft && !props.line.isMetaLineLeft;
  },
  interopLeftAttributes(props) {
    if (props.inline) {
      return getInteropInlineAttributes(props.line.left);
    }

    return getInteropOldSideAttributes(props.line.left);
  },
  interopRightAttributes(props) {
    return getInteropNewSideAttributes(props.line.right);
  },
  conflictText(line) {
    return line.type === CONFLICT_MARKER_THEIR ? 'HEAD//our changes' : 'origin//their changes';
  },
  mounted() {
    this.scrollToLineIfNeededParallel(this.line);
  },
  methods: {
    ...mapActions('diffs', ['scrollToLineIfNeededParallel']),
  },
  CONFLICT_MARKER,
  CONFLICT_MARKER_THEIR,
  CONFLICT_OUR,
  CONFLICT_THEIR,
};
</script>

<template functional>
  <div :class="$options.classNameMap(props)" class="diff-grid-row diff-tr line_holder">
    <div
      data-testid="left-side"
      class="diff-grid-left left-side"
      v-bind="$options.interopLeftAttributes(props)"
      @dragover.prevent
      @dragenter="listeners.enterdragging({ ...props.line.left, index: props.index })"
      @dragend="listeners.stopdragging"
    >
      <template v-if="props.line.left && props.line.left.type !== $options.CONFLICT_MARKER">
        <div
          :class="$options.classNameMapCellLeft(props)"
          data-testid="left-line-number"
          class="diff-td diff-line-num"
          data-qa-selector="new_diff_line_link"
        >
          <span
            v-if="
              !props.line.left.isConflictMarker &&
              $options.shouldRenderCommentButton(props) &&
              !props.line.hasDiscussionsLeft
            "
            class="add-diff-note tooltip-wrapper js-tooltip-test"
            :title="props.line.left.addCommentTooltip"
          >
            <div
              data-testid="left-comment-button"
              role="button"
              tabindex="0"
              :draggable="!props.line.left.commentsDisabled"
              type="button"
              class="add-diff-note unified-diff-components-diff-note-button note-button js-add-diff-note-button"
              data-qa-selector="diff_comment_button"
              :disabled="props.line.left.commentsDisabled"
              :aria-disabled="props.line.left.commentsDisabled"
              @click="listeners.showCommentForm(props.line.left.line_code)"
              @keydown.enter="listeners.showCommentForm(props.line.left.line_code)"
              @keydown.space="listeners.showCommentForm(props.line.left.line_code)"
              @dragstart="listeners.startdragging(props.line.left)"
            ></div>
          </span>
          <a
            v-if="props.line.left.old_line && props.line.left.type !== $options.CONFLICT_THEIR"
            :data-linenumber="props.line.left.old_line"
            :href="props.line.lineHrefOld"
            @click="listeners.setHighlightedRow(props.line.lineCode)"
          >
          </a>
          <component
            :is="$options.DiffGutterAvatars"
            v-if="props.line.hasDiscussionsLeft"
            :discussions="props.line.left.discussions"
            :discussions-expanded="props.line.left.discussionsExpanded"
            data-testid="left-discussions"
            @toggleLineDiscussions="
              listeners.toggleLineDiscussions({
                lineCode: props.line.left.line_code,
                expanded: !props.line.left.discussionsExpanded,
              })
            "
          />
        </div>
        <div
          v-if="props.inline"
          :class="$options.classNameMapCellLeft(props)"
          class="diff-td diff-line-num"
        >
          <a
            v-if="props.line.left.new_line && props.line.left.type !== $options.CONFLICT_OUR"
            :data-linenumber="props.line.left.new_line"
            :href="props.line.lineHrefOld"
            @click="listeners.setHighlightedRow(props.line.lineCode)"
          >
          </a>
        </div>
        <div
          :title="$options.coverageStateLeft(props).text"
          :class="[
            $options.parallelViewLeftLineType(props),
            $options.coverageStateLeft(props).class,
          ]"
          class="diff-td line-coverage left-side"
        ></div>
        <div
          class="diff-td line-codequality left-side"
          :class="$options.parallelViewLeftLineType(props)"
        >
          <component
            :is="$options.CodeQualityGutterIcon"
            v-if="$options.showCodequalityLeft(props)"
            :codequality="props.line.left.codequality"
          />
        </div>
        <div
          :id="props.line.left.line_code"
          :key="props.line.left.line_code"
          :class="[$options.parallelViewLeftLineType(props), { parallel: !props.inline }]"
          class="diff-td line_content with-coverage left-side"
          data-testid="left-content"
        >
          <strong v-if="props.line.left.isConflictMarker">{{
            $options.conflictText(props.line.left)
          }}</strong>
          <span v-else v-html="props.line.left.rich_text"></span>
        </div>
      </template>
      <template
        v-else-if="
          !props.inline || (props.line.left && props.line.left.type === $options.CONFLICT_MARKER)
        "
      >
        <div data-testid="left-empty-cell" class="diff-td diff-line-num old_line empty-cell">
          &nbsp;
        </div>
        <div v-if="props.inline" class="diff-td diff-line-num old_line empty-cell"></div>
        <div class="diff-td line-coverage left-side empty-cell"></div>
        <div v-if="props.inline" class="diff-td line-codequality left-side empty-cell"></div>
        <div
          class="diff-td line_content with-coverage left-side empty-cell"
          :class="[{ parallel: !props.inline }]"
        ></div>
      </template>
    </div>
    <div
      v-if="!props.inline"
      data-testid="right-side"
      class="diff-grid-right right-side"
      v-bind="$options.interopRightAttributes(props)"
      @dragover.prevent
      @dragenter="listeners.enterdragging({ ...props.line.right, index: props.index })"
      @dragend="listeners.stopdragging"
    >
      <template v-if="props.line.right">
        <div :class="$options.classNameMapCellRight(props)" class="diff-td diff-line-num new_line">
          <template v-if="props.line.right.type !== $options.CONFLICT_MARKER_THEIR">
            <span
              v-if="$options.shouldRenderCommentButton(props) && !props.line.hasDiscussionsRight"
              class="add-diff-note tooltip-wrapper"
              :title="props.line.right.addCommentTooltip"
            >
              <div
                data-testid="right-comment-button"
                role="button"
                tabindex="0"
                :draggable="!props.line.right.commentsDisabled"
                type="button"
                class="add-diff-note unified-diff-components-diff-note-button note-button js-add-diff-note-button"
                :disabled="props.line.right.commentsDisabled"
                :aria-disabled="props.line.right.commentsDisabled"
                @click="listeners.showCommentForm(props.line.right.line_code)"
                @keydown.enter="listeners.showCommentForm(props.line.right.line_code)"
                @keydown.space="listeners.showCommentForm(props.line.right.line_code)"
                @dragstart="listeners.startdragging(props.line.right)"
              ></div>
            </span>
          </template>
          <a
            v-if="props.line.right.new_line"
            :data-linenumber="props.line.right.new_line"
            :href="props.line.lineHrefNew"
            @click="listeners.setHighlightedRow(props.line.lineCode)"
          >
          </a>
          <component
            :is="$options.DiffGutterAvatars"
            v-if="props.line.hasDiscussionsRight"
            :discussions="props.line.right.discussions"
            :discussions-expanded="props.line.right.discussionsExpanded"
            data-testid="right-discussions"
            @toggleLineDiscussions="
              listeners.toggleLineDiscussions({
                lineCode: props.line.right.line_code,
                expanded: !props.line.right.discussionsExpanded,
              })
            "
          />
        </div>
        <div
          :title="$options.coverageStateRight(props).text"
          :class="[
            props.line.right.type,
            $options.coverageStateRight(props).class,
            { hll: props.isHighlighted, hll: props.isCommented },
          ]"
          class="diff-td line-coverage right-side"
        ></div>
        <div
          class="diff-td line-codequality right-side"
          :class="[props.line.right.type, { hll: props.isHighlighted, hll: props.isCommented }]"
        >
          <component
            :is="$options.CodeQualityGutterIcon"
            v-if="$options.showCodequalityRight(props)"
            :codequality="props.line.right.codequality"
          />
        </div>
        <div
          :id="props.line.right.line_code"
          :key="props.line.right.rich_text"
          :class="[
            props.line.right.type,
            {
              hll: props.isHighlighted,
              hll: props.isCommented,
            },
          ]"
          class="diff-td line_content with-coverage right-side parallel"
        >
          <strong v-if="props.line.right.type === $options.CONFLICT_MARKER_THEIR">{{
            $options.conflictText(props.line.right)
          }}</strong>
          <span v-else v-html="props.line.right.rich_text"></span>
        </div>
      </template>
      <template v-else>
        <div data-testid="right-empty-cell" class="diff-td diff-line-num old_line empty-cell"></div>
        <div class="diff-td line-coverage right-side empty-cell"></div>
        <div class="diff-td line-codequality right-side empty-cell"></div>
        <div class="diff-td line_content with-coverage right-side empty-cell parallel"></div>
      </template>
    </div>
  </div>
</template>
