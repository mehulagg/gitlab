<script>
export default {
  props: {
    storageKey: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: '',
    },
    persist: {
      type: Boolean,
      required: false,
      default: true,
    }
  },
  watch: {
    value(newVal) {
      this.saveValue(newVal);
    },
  },
  mounted() {
    // On mount, trigger update if we actually have a localStorageValue
    const value = this.getValue();

    if (value && this.value !== value) {
      this.$emit('input', value);
    }
  },
  methods: {
    getValue() {
      return localStorage.getItem(this.storageKey);
    },
    saveValue(val) {
      debugger
      if (!this.persist) return;

      localStorage.setItem(this.storageKey, val);
    },
  },
  render() {
    return this.$slots.default;
  },
};
</script>
