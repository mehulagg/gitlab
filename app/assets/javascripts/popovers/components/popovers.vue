<script>
import { GlPopover, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { uniqueId } from 'lodash';

const newPopover = (element, config = {}) => {
  const {
    title,
    content,
    placement,
    container,
    boundary,
    html,
    triggers,
    trigger,
  } = element.dataset;

  return {
    id: uniqueId('gl-popover'),
    target: element,
    title,
    content,
    html,
    placement,
    container,
    boundary,
    triggers: triggers || trigger,
    disabled: !title,
    ...config,
  };
};

export default {
  components: {
    GlPopover,
  },
  directives: {
    SafeHtml,
  },
  data() {
    return {
      popovers: [],
    };
  },
  created() {
    this.observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        mutation.removedNodes.forEach(this.dispose);
      });
    });
  },
  beforeDestroy() {
    this.observer.disconnect();
  },
  methods: {
    addPopovers(elements, config) {
      const newPopovers = elements
        .filter(element => !this.popoverExists(element))
        .map(element => newPopover(element, config));

      newPopovers.forEach(popover => this.observe(popover));

      this.popovers.push(...newPopovers);
    },
    observe(popover) {
      this.observer.observe(popover.target.parentElement, {
        childList: true,
      });
    },
    dispose(target) {
      if (!target) {
        this.popovers = [];
      } else {
        const index = this.popovers.indexOf(this.findPopoverByTarget(target));

        if (index > -1) {
          this.popovers.splice(index, 1);
        }
      }
    },
    popoverExists(element) {
      return Boolean(this.findPopoverByTarget(element));
    },
    findPopoverByTarget(element) {
      return this.popovers.find(popover => popover.target === element);
    },
  },
};
</script>
<template>
  <div>
    <gl-popover
      v-for="(popover, index) in popovers"
      :id="popover.id"
      :ref="popover.id"
      :key="index"
      :target="popover.target"
      :triggers="popover.triggers"
      :placement="popover.placement"
      :container="popover.container"
      :boundary="popover.boundary"
      :disabled="popover.disabled"
      :show="popover.show"
    >
      <template #title>
        <span v-if="popover.html" v-safe-html="popover.title"></span>
        <span v-else>{{ popover.title }}</span>
      </template>
      <span v-if="popover.html" v-safe-html="popover.content"></span>
      <span v-else>{{ popover.content }}</span>
    </gl-popover>
  </div>
</template>
