<script>
import KeepAliveSlots from './keep_alive_slots.vue';
import TopNavContainerView from './top_nav_container_view.vue';
import TopNavMenuItem from './top_nav_menu_item.vue';

const ACTIVE_CLASS = 'gl-bg-gray-50! gl-shadow-none! active';

export default {
  components: {
    KeepAliveSlots,
    TopNavContainerView,
    TopNavMenuItem,
  },
  props: {
    primary: {
      type: Array,
      required: false,
      default: () => [],
    },
    secondary: {
      type: Array,
      required: false,
      default: () => [],
    },
    views: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      activeId: '',
    };
  },
  computed: {
    allMenuItems() {
      return [...this.primary, ...this.secondary];
    },
    activeMenuItem() {
      return this.allMenuItems.find((x) => x.id === this.activeId);
    },
    activeView() {
      return this.activeMenuItem?.view;
    },
    menuClass() {
      if (!this.activeView) {
        return 'gl-w-full';
      }

      return '';
    },
  },
  created() {
    this.activeId = this.allMenuItems.find((x) => x.active)?.id;
  },
  methods: {
    onClick({ id, href }) {
      // If we're a link, let's just do the default behavior so the view won't change
      if (href) {
        return;
      }

      this.activeId = id;
    },
    menuItemClass(menuItem) {
      if (menuItem.id === this.activeId) {
        return ACTIVE_CLASS;
      }

      return '';
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-stretch top-nav-content">
    <div class="gl-w-grid-size-30 gl-flex-shrink-0 gl-bg-gray-10" :class="menuClass">
      <div class="gl-p-3 gl-h-full gl-display-flex gl-align-items-stretch gl-flex-direction-column">
        <div>
          <top-nav-menu-item
            v-for="menu in primary"
            :key="menu.id"
            :class="menuItemClass(menu)"
            :menu-item="menu"
            @click="onClick(menu)"
          />
        </div>
        <div
          v-if="secondary.length"
          class="gl-mt-auto gl-border-1 gl-border-t-solid gl-border-gray-100"
        >
          <top-nav-menu-item
            v-for="menu in secondary"
            :key="menu.id"
            :class="menuItemClass(menu)"
            :menu-item="menu"
            @click="onClick(menu)"
          />
        </div>
      </div>
    </div>
    <keep-alive-slots
      v-show="activeView"
      :slot-key="activeView"
      class="gl-w-grid-size-40 gl-overflow-hidden gl-p-3"
    >
      <template #projects>
        <top-nav-container-view
          frequent-items-dropdown-type="projects"
          frequent-items-vuex-module="frequentProjects"
          v-bind="views.projects"
        />
      </template>
      <template #groups>
        <top-nav-container-view
          frequent-items-dropdown-type="groups"
          frequent-items-vuex-module="frequentGroups"
          v-bind="views.groups"
        />
      </template>
    </keep-alive-slots>
  </div>
</template>
