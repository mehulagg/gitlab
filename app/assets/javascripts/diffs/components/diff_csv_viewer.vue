<script>
import { GlTable } from '@gitlab/ui';
import Papa from 'papaparse';
import { stripHtml } from '~/lib/utils/text_utility';

export default {
  components: {
    GlTable,
  },
  props: {
    diffFile: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      items: [],
    };
  },
  mounted() {
    const parsed = Papa.parse(
      this.diffFile.highlighted_diff_lines
        .map((h) => (h.line_code ? `<${h.line_code}>${stripHtml(h.rich_text)}` : h.rich_text))
        .join('\n'),
      {
        skipEmptyLines: true,
      },
    );
    /* eslint-disable no-param-reassign */
    parsed.data.forEach((d) => {
      const lineCode = d[0].match(/<(.*?)>/);
      const matchedLine = this.diffFile.highlighted_diff_lines.find(
        (h) => h.line_code === lineCode[1],
      );
      if (matchedLine) {
        d[0] = d[0].replace(lineCode[0], '');
        d.unshift(matchedLine.old_line);
        d.unshift(matchedLine.new_line);
      }
    }, this);
    /* eslint-enable no-param-reassign */
    this.items = parsed.data;
  },
};
</script>

<template>
  <gl-table
    :empty-text="__('No CSV data to display.')"
    :items="items"
    :fields="$options.fields"
    show-empty
    thead-class="gl-display-none"
  />
</template>
