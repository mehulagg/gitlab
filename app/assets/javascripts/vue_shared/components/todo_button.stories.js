/* eslint-disable @gitlab/require-i18n-strings */

import TodoButton from './todo_button.vue';

export default {
  component: TodoButton,
  title: 'components/todo_button',
};

export const Primary = () => ({
  components: { TodoButton },
  template: '<todo-button />',
  argTypes: {
    isTodo: { description: 'True if to-do is unresolved (i.e. not "done")', control: 'boolean' },
  },
});
