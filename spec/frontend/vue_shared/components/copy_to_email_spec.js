import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import CopyEmailToClipboard from '~/vue_shared/components/copy_email_to_clipboard.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';

describe('CopyEmailToClipboard component', () => {
  let props;
  let wrapper;

  const createComponent = propsData => {
    wrapper = shallowMount(CopyEmailToClipboard, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });
});
