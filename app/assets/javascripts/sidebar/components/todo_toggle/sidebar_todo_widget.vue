<script>
import { GlButton, GlLoadingIcon, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import createFlash from '~/flash';
import { __, sprintf } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import { todoQueries, TodoMutationTypes, todoMutations } from '~/sidebar/constants';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLoadingIcon,
    SidebarEditableItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    id: {
      type: String,
      required: true,
    },
    iid: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      hasTodo: false,
      loading: false,
      todoId: null,
    };
  },
  apollo: {
    hasTodo: {
      query() {
        return todoQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: String(this.iid),
        };
      },
      update(data) {
        return data.workspace?.issuable?.currentUserTodos.nodes.length > 0;
      },
      result({ data }) {
        this.todoId = data.workspace?.issuable?.currentUserTodos.nodes[0]?.id;
        this.$emit('todoUpdated', data.workspace?.issuable?.currentUserTodos.nodes.length > 0);
      },
      error() {
        createFlash({
          message: sprintf(__('Something went wrong while setting %{issuableType} todo.'), {
            issuableType: this.issuableType,
          }),
        });
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries?.hasTodo?.loading || this.loading;
    },
    todoMutationType() {
      if (this.hasTodo) {
        return TodoMutationTypes.MarkDone;
      }
      return TodoMutationTypes.Create;
    },
    buttonLabel() {
      return this.hasTodo ? this.$options.i18n.markDone : this.$options.i18n.addTodo;
    },
    collapsedButtonIcon() {
      return this.hasTodo ? 'todo-done' : 'todo-add';
    },
  },
  methods: {
    toggleTodo() {
      this.loading = true;
      this.$apollo
        .mutate({
          mutation: todoMutations[this.todoMutationType],
          variables: {
            input: {
              targetId: !this.hasTodo ? this.id : undefined,
              id: this.hasTodo ? this.todoId : undefined,
            },
          },
        })
        .then(
          ({
            data: {
              todoMutation: { errors, todo },
            },
          }) => {
            if (errors.length) {
              createFlash({
                message: errors[0],
              });
            } else {
              this.todoId = todo?.id;
              this.hasTodo = !this.hasTodo;
            }
          },
        )
        .catch(() => {
          createFlash({
            message: sprintf(
              __('Something went wrong while setting %{issuableType} notifications.'),
              {
                issuableType: this.issuableType,
              },
            ),
          });
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
  i18n: {
    addTodo: __('Add a to do'),
    markDone: __('Mark as done'),
  },
};
</script>

<template>
  <sidebar-editable-item ref="editable" :loading="isLoading" :can-edit="false" class="todo">
    <template #collapsed>
      <gl-button
        v-gl-tooltip.left.viewport
        :title="buttonLabel"
        :aria-label="buttonLabel"
        :data-issuable-id="id"
        :data-issuable-type="issuableType"
        type="button"
        @click="toggleTodo"
      >
        <gl-icon
          class="sidebar-collapsed-icon"
          :class="{ 'todo-undone': hasTodo }"
          :name="collapsedButtonIcon"
        />
        <span class="issuable-todo-inner">{{ buttonLabel }}</span>
        <gl-loading-icon v-show="isLoading" :inline="true" />
      </gl-button>
    </template>
  </sidebar-editable-item>
</template>
