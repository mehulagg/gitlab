<script>
import { linkRegex } from '../../utils';

import LineNumber from './line_number.vue';

export default {
  functional: true,
  props: {
    line: {
      type: Object,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
  },
  render(h, { props }) {
    const { line, path } = props;

    const chars = line.content.map(content => {
      // Feature flag: ci_job_line_links
      if (gon.features.ciJobLineLinks) {
        return h('span', {
          class: ['gl-white-space-pre-wrap', content.style],
          domProps: {
            innerHTML: content.text.replace(
              linkRegex,
              '<a href="$&" rel="nofollow noopener">$&</a>',
            ),
          },
        });
      }

      return h(
        'span',
        {
          class: ['gl-white-space-pre-wrap', content.style],
        },
        content.text,
      );
    });

    return h('div', { class: 'js-line log-line' }, [
      h(LineNumber, {
        props: {
          lineNumber: line.lineNumber,
          path,
        },
      }),
      ...chars,
    ]);
  },
};
</script>
