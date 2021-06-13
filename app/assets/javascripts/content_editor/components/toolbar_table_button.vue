<script>
import { GlDropdown, GlDropdownDivider, GlDropdownForm, GlButton } from '@gitlab/ui';
import { Editor as TiptapEditor } from '@tiptap/vue-2';
import { __, sprintf } from '~/locale';

export const tableContentType = 'table';

const MIN_ROWS = 3;
const MIN_COLS = 3;
const MAX_ROWS = 8;
const MAX_COLS = 8;

function clamp(n, min, max) {
  return Math.max(Math.min(n, max), min);
}

export default {
  components: {
    GlDropdown,
    GlDropdownDivider,
    GlDropdownForm,
    GlButton,
  },
  props: {
    tiptapEditor: {
      type: TiptapEditor,
      required: true,
    },
  },
  data() {
    return {
      maxRows: MIN_ROWS,
      maxCols: MIN_COLS,
      rows: 1,
      cols: 1,
    };
  },
  methods: {
    repeat(until) {
      const arr = [];
      for (let i = 1; i <= until; i += 1) {
        arr.push(i);
      }
      return arr;
    },
    setRowsAndCols(rows, cols) {
      this.rows = rows;
      this.cols = cols;
      this.maxRows = clamp(rows + 1, MIN_ROWS, MAX_ROWS);
      this.maxCols = clamp(cols + 1, MIN_COLS, MAX_COLS);
    },
    insertTable() {
      this.tiptapEditor
        .chain()
        .focus()
        .insertTable({
          rows: this.rows,
          cols: this.cols,
          withHeaderRow: true,
        })
        .run();
    },
    getButtonLabel(rows, cols) {
      return sprintf(__('Insert a %{rows}x%{cols} table.'), { rows, cols });
    },
  },
};
</script>
<template>
  <gl-dropdown size="small" category="tertiary" icon="table">
    <gl-dropdown-form class="gl-px-3! gl-w-auto!">
      <div class="gl-w-auto!">
        <span v-for="c of repeat(maxCols)" :key="c">
          <span v-for="r of repeat(maxRows)" :key="r">
            <gl-button
              :ref="`table-${r}-${c}`"
              :class="{ active: r <= rows && c <= cols }"
              :aria-label="getButtonLabel(r, c)"
              variant="default"
              category="secondary"
              class="gl-display-inline! gl-px-0! gl-mr-3 gl-mb-3 gl-w-5!"
              @mouseover="setRowsAndCols(r, c)"
              @click="insertTable()"
            />
          </span>
          <br />
        </span>
        <gl-dropdown-divider />
        {{ getButtonLabel(rows, cols) }}
      </div>
    </gl-dropdown-form>
  </gl-dropdown>
</template>
<style scoped>
button {
  border-radius: 0px !important;
}
</style>
