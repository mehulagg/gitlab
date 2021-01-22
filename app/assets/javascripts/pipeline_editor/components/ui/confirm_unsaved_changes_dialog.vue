<script>
export default {
  props: {
    hasUnsavedChanges: {
      type: Boolean,
      required: true,
    },
  },
  created() {
    window.addEventListener('beforeunload', this.confirmChanges);
  },
  destroyed() {
    window.removeEventListener('beforeunload', this.confirmChanges);
  },
  methods: {
    confirmChanges(e) {
      if (this.hasUnsavedChanges) {
        e.preventDefault();
        e.returnValue = '';
      }
    },
  },
  render: () => null,
};
</script>
