<script>
import { GlSprintf } from '@gitlab/ui';
import { SEVERITY_CLASS_NAME_MAP } from './constants';

const makeSeveritySlot = (createElement, severity) => ({ content }) =>
  createElement('strong', { class: SEVERITY_CLASS_NAME_MAP[severity] }, content);

export default {
  functional: true,
  props: {
    message: {
      type: String,
      required: true,
    },
  },
  render(createElement, context) {
    const { message } = context.props;

    return createElement(GlSprintf, {
      props: { message },
      scopedSlots: {
        critical: makeSeveritySlot(createElement, 'critical'),
        high: makeSeveritySlot(createElement, 'high'),
      },
    });
  },
};
</script>
