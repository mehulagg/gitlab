<script>
import VirtualList from 'vue-virtual-scroll-list';

export default {
  name: 'SmartVirtualList',
  components: { VirtualList },
  /*
    The following props map one-to-one to the vue-virtual-scroll-list props.
    The reason we call out these ones specifically is so that they can be
    used in our plain item list. See the vue-virtual-scroll-list docs for
    more props that can be used: https://github.com/tangbc/vue-virtual-scroll-list#props-type
  */
  props: {
    dataKey: { type: [String, Function], required: true },
    dataSources: { type: Array, required: true },
    dataComponent: { type: [Object, Function], required: true },
    keeps: { type: Number, required: false, default: () => 30 }, // 30 is the default vue-virtual-scroll-list uses
    extraProps: { type: Object, required: false, default: () => ({}) },
    rootTag: { type: String, required: false, default: () => 'div' },
    wrapTag: { type: String, required: false, default: () => 'div' },
    wrapClass: { type: String, required: false, default: () => null },
  },
  computed: {
    shouldUseVirtualList() {
      return this.dataSources.length > this.keeps;
    },
  },
};
</script>
<template>
  <virtual-list
    v-if="shouldUseVirtualList"
    v-bind="$attrs"
    :data-key="dataKey"
    :data-sources="dataSources"
    :data-component="dataComponent"
    :keeps="keeps"
    :root-tag="rootTag"
    :wrap-tag="wrapTag"
    :wrap-class="wrapClass"
    data-testid="smart-virtual-list"
  />
  <component :is="rootTag" v-else data-testid="smart-virtual-list-plain">
    <component :is="wrapTag" :class="wrapClass" data-testid="smart-virtual-list-plain-wrapper">
      <component
        :is="dataComponent"
        v-for="(source, index) in dataSources"
        :key="source[dataKey]"
        :index="index"
        :source="source"
        :extra-props="extraProps"
        :data-testid="`smart-virtual-list-plain-item-${source[dataKey]}`"
      />
    </component>
  </component>
</template>
