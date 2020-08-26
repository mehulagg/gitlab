<script>
import { mapState, mapGetters, mapActions } from 'vuex';

import Todo from '~/sidebar/components/todo_toggle/todo.vue';

export default {
  components: {
    Todo,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['epicId', 'todoExists', 'epicTodoToggleInProgress']),
    ...mapGetters(['isUserSignedIn']),
  },
  methods: {
    ...mapActions(['toggleTodo']),
  },

  emits: [],
};
</script>

<template>
  <div :class="{ 'block todo': isUserSignedIn && sidebarCollapsed }">
    <todo
      :collapsed="sidebarCollapsed"
      :issuable-id="epicId"
      :is-todo="todoExists"
      :is-action-active="epicTodoToggleInProgress"
      issuable-type="epic"
      @toggleTodo="toggleTodo"
    />
  </div>
</template>
