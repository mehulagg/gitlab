<script>
import { isExperimentVariant } from '../utils';

export default {
  props: {
    name: {
      type: String,
      required: true,
    },
  },
  render() {
    const variantNames = Object.keys(this.$slots);

    if (!variantNames.length) {
      return;
    }

    const variant = variantNames.find((v) => isExperimentVariant(this.name, v)) || variantNames[0];

    // eslint-disable-next-line consistent-return
    return this.$slots[variant];
  },
};
</script>
