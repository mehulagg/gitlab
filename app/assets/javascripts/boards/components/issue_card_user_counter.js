export default {
  name: 'IssueCardUserCounter',
  props: {
    count: { type: Number, required: true },
  },
  computed: {
    tooltipTitle() {
      return `+${this.count} more assignees`;
    },
    text() {
      if (this.count < 99) {
        return `+${this.count}`;
      }

      return '99+';
    },
  },
  template: `
    <span
      class="avatar-counter has-tooltip js-no-trigger"
      data-container="body"
      data-placement="bottom"
      data-line-type="old"
      :data-original-title="tooltipTitle">
      {{ text }}
    </span>
  `,
};
