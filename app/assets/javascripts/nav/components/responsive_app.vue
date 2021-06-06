<script>
import KeepAliveSlots from '~/vue_shared/components/keep_alive_slots.vue';
import eventHub, { EVENT_RESPONSIVE_TOGGLE } from '../event_hub';
import ResponsiveHome from './responsive_home.vue';

export default {
  components: {
    ResponsiveHome,
    KeepAliveSlots,
  },
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      activeView: 'home',
    };
  },
  created() {
    eventHub.$on(EVENT_RESPONSIVE_TOGGLE, this.onToggle);
  },
  beforeDestroy() {
    eventHub.$off(EVENT_RESPONSIVE_TOGGLE, this.onToggle);
  },
  methods: {
    onToggle() {
      document.body.classList.toggle('top-nav-responsive-open');
    },
  },
};
</script>

<template>
  <keep-alive-slots :slot-key="activeView">
    <template #home>
      <responsive-home :nav-data="navData" />
    </template>
  </keep-alive-slots>
</template>
