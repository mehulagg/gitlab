/* eslint-disable no-underscore-dangle */
const getComponentName = options => {
  const name = options._componentTag;
  let file = options.__file;
  if (file) {
    file = file
      .split('/')
      .pop()
      .split('.vue')
      .shift();
  }
  return name || file;
};

const ComponentPerformancePlugin = {
  install(Vue, options) {
    Vue.mixin({
      beforeCreate() {
        const componentName = getComponentName(this.$options);
        if (options?.components?.indexOf(componentName) !== -1) {
          if (!performance.getEntriesByName(`${componentName}-start`).length) {
            performance.mark(`${componentName}-start`);
          }
        }
      },
      mounted() {
        const componentName = getComponentName(this.$options);
        if (options?.components?.indexOf(componentName) !== -1) {
          this.$nextTick(() => {
            window.requestAnimationFrame(() => {
              if (!performance.getEntriesByName(`${componentName}-end`).length) {
                performance.mark(`${componentName}-end`);
                performance.measure(`${componentName}-component`, `${componentName}-start`);
              }
            });
          });
        }
      },
    });
  },
};

export default ComponentPerformancePlugin;
