<script>
import { GlButtonGroup, GlButton } from '@gitlab/ui';
import { createDiffData } from './diff_utils';
import { DIFF, BEFORE, AFTER } from './constants';

export default {
  components: {
    GlButtonGroup,
    GlButton,
  },
  props: {
    before: {
      type: String,
      required: true,
    },
    after: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      view: DIFF,
    };
  },
  viewType: {
    DIFF,
  },
  computed: {
    diffData() {
      return createDiffData(this.before, this.after);
    },
    visibleDiffData(){
      return this.diffData.filter(this.shouldShowLine);
    },
    isDiffView() {
      return this.view === DIFF;
    },
    isBeforeView() {
      return this.view === BEFORE;
    },
    isAfterView() {
      return this.view === AFTER;
    },
  },
  methods: {
    shouldShowLine(line) {
      return (
        this.view === DIFF ||
        line.type === 'normal' ||
        (line.type === 'removed' && this.view === BEFORE) ||
        (line.type === 'added' && this.view === AFTER)
      );
    },
    changeClass(change) {
      return {
        normal: '',
        added: 'new',
        removed: 'old',
      }[change.type];
    },
    changeClassIDiff(action) {
      if (action.removed || action.added) {
        return 'idiff';
      }
      return '';
    },
    setDiffViewType() {
      this.view = DIFF;
    },
    setBeforeViewType() {
      this.view = BEFORE;
    },
    setAfterViewType() {
      this.view = AFTER;
    },
  },
  userColorScheme: window.gon.user_color_scheme,
};
</script>

<template>
  <div class="gl-rounded-base gl-border-solid gl-border-1 gl-border-gray-100 ">
    <div class="gl-overflow-hidden gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-p-3">
      <gl-button-group class="gl-display-flex gl-float-right">
        <gl-button
          :class="{ selected: isDiffView }"
          :data-view-type="$options.viewType.DIFF"
          @click="setDiffViewType"
        >
          {{ s__('GenericReport|Diff') }}
        </gl-button>
        <gl-button
          :class="{ selected: isBeforeView }"
          :data-view-type="$options.viewType.DIFF"
          @click="setBeforeViewType"
        >
          {{ s__('GenericReport|Before') }}
        </gl-button>
        <gl-button
          :class="{ selected: isAfterView }"
          :data-view-type="$options.viewType.DIFF"
          @click="setAfterViewType"
        >
          {{ s__('Genericreport|After') }}
        </gl-button>
      </gl-button-group>
    </div>
    <table class="code" :class="$options.userColorScheme">
      <tr
        v-for="(line, idx) in visibleDiffData"
        :key="idx"
        :class="changeClass(line)"
        class="line_holder"
      >
        <td class="diff-line-num old_line gl-border-t-0 gl-border-b-0" :class="changeClass(line)">
          {{ line.old_line }}
        </td>
        <td class="diff-line-num new_line gl-border-t-0 gl-border-b-0" :class="changeClass(line)">
          {{ line.new_line }}
        </td>
        <td class="line_content" :class="changeClass(line)">
          <span
            v-for="(action, actionIdx) in line.actions"
            :key="actionIdx"
            class="left right"
            :class="changeClassIDiff(action)"
            >{{ action.value }}</span
          >
        </td>
      </tr>
    </table>
  </div>
</template>
