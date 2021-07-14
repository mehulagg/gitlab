/* eslint-disable @gitlab/require-i18n-strings */
import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import ClipboardButton from './clipboard_button.vue';

Vue.use(Translate);

export default {
  component: ClipboardButton,
  title: 'vue_shared/components/clipboard_button',
};

const Template = (args, { argTypes }) => ({
  components: { ClipboardButton },
  props: Object.keys(argTypes),
  template: '<clipboard-button v-bind="$props" />',
});

export const Default = Template.bind({});
Default.args = {
  text: 'Heyo!',
  title: 'Copy me!',
};
Default.argTypes = {
  click: { action: 'clicked' },
};
