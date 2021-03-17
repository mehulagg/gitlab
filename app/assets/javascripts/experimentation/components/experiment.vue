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

    const variant =
      variantNames.find((variant) => isExperimentVariant(this.name, variant)) || variantNames[0];

    return this.$slots[variant];
  },
};
</script>
