import { mount } from '@vue/test-utils';

import boardsStore from '~/boards/stores/boards_store';
import boardForm from '~/boards/components/board_form.vue';
import DeprecatedModal from '~/vue_shared/components/deprecated_modal.vue';

describe('board_form.vue', () => {
  let wrapper;

  const propsData = {
    canAdminBoard: false,
    labelsPath: `${gl.TEST_HOST}/labels/path`,
    milestonePath: `${gl.TEST_HOST}/milestone/path`,
  };

  const findModal = () => wrapper.find(DeprecatedModal);

  beforeEach(() => {
    boardsStore.state.currentPage = 'edit';
    wrapper = mount(boardForm, { propsData });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('methods', () => {
    describe('cancel', () => {
      it('resets currentPage', () => {
        wrapper.vm.cancel();
        expect(boardsStore.state.currentPage).toBe('');
      });
    });
  });

  describe('buttons', () => {
    it('cancel button triggers cancel()', () => {
      wrapper.setMethods({ cancel: jest.fn() });
      findModal().vm.$emit('cancel');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.vm.cancel).toHaveBeenCalled();
      });
    });
  });
});
