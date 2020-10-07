import ExtensionBase from './base.vue';

export const extensions = [];

export const registerExtension = extension => {
  extensions.push({
    extends: ExtensionBase,
    name: extension.name,
    props: extension.props,
    computed: {
      ...Object.keys(extension.computed).reduce(
        (acc, computedKey) => ({
          ...acc,
          [computedKey]() {
            return extension.computed[computedKey];
          },
        }),
        {},
      ),
    },
    methods: {
      ...extension.methods,
    },
  });
};
