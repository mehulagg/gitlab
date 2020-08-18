<script>
import createEventHub from '~/helpers/event_hub_factory';

const stores = new Map();

export default {
  props: {
    type: {
      type: String,
      required: true,
    },
  },

  watch: {
    type: {
      immediate: true,
      handler(newType, oldType) {
        const storeConfig = stores.get(this.$store);

        if (oldType) {
          storeConfig.emitter.$off(oldType, this.emitEvent);
        }

        storeConfig.emitter.$on(newType, this.emitEvent);
      },
    },
  },

  beforeCreate() {
    if (!this.$store) {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      throw new Error('This component is intended to be used in Vuex apps');
    }

    if (!stores.has(this.$store)) {
      const storeConfig = {
        subscribersCount: 1,
        emitter: createEventHub(),
        unsubscribeFn: this.$store.subscribe(mutation => {
          storeConfig.emitter.$emit(mutation.type, mutation.payload);
        }),
      };

      stores.set(this.$store, storeConfig);
    } else {
      const storeConfig = stores.get(this.$store);
      storeConfig.subscribersCount += 1;
    }
  },

  beforeDestroy() {
    const storeConfig = stores.get(this.$store);

    storeConfig.subscribersCount -= 1;
    if (storeConfig.subscribersCount === 0) {
      storeConfig.unsubscribeFn();
      stores.delete(this.$store);
    } else {
      storeConfig.emitter.$off(this.type, this.emitEvent);
    }
  },

  methods: {
    emitEvent(payload) {
      this.$emit('mutation', payload);
    },
  },

  render: () => null,
};
</script>
