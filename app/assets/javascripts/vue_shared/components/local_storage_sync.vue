<script>
import { isString } from 'lodash';

export default {
  props: {
    storageKey: {
      type: String,
      required: true,
    },
    value: {
      type: [String, Number, Boolean, Array, Object],
      required: false,
      default: '',
    },
    json: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  watch: {
    value(newVal) {
      this.saveValue(this.serialize(newVal));
    },
  },
  mounted() {
    if (!this.json && !isString(this.value)) {
      throw new Error(
        // eslint-disable-next-line @gitlab/require-i18n-strings
        'Invalid prop: type check failed for prop "value". Expected String. Hint: Use the "json" prop to use non-string values',
      );
    }

    // On mount, trigger update if we actually have a localStorageValue
    const value = this.getValue();

    // Receiving `null` from localStorage means there's no stored value
    if (value !== null && this.serialize(this.value) !== value) {
      this.$emit('input', this.deserialize(value));
    }
  },
  methods: {
    getValue() {
      return localStorage.getItem(this.storageKey);
    },
    saveValue(val) {
      localStorage.setItem(this.storageKey, val);
    },
    serialize(val) {
      return this.json ? JSON.stringify(val) : val;
    },
    deserialize(val) {
      return this.json ? JSON.parse(val) : val;
    },
  },
  render() {
    return this.$slots.default;
  },
};
</script>
