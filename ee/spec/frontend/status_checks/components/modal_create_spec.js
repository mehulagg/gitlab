import { GlButton, GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ModalCreate, { i18n } from 'ee/status_checks/components/modal_create.vue';
import { stubComponent } from 'helpers/stub_component';

const modalId = 'status-checks-add-modal';

describe('Modal create', () => {
  let wrapper;
  const glModalDirective = jest.fn();

  const createWrapper = () => {
    wrapper = shallowMount(ModalCreate, {
      directives: {
        glModal: {
          bind(el, { modifiers }) {
            glModalDirective(modifiers);
          },
        },
      },
      stubs: {
        GlButton: stubComponent(GlButton, {
          props: ['v-gl-modal'],
        }),
      },
    });

    wrapper.vm.$refs.modal.hide = jest.fn();
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findAddBtn = () => wrapper.findComponent(GlButton);
  const findModal = () => wrapper.findComponent(GlModal);

  describe('Add button', () => {
    it('renders', () => {
      expect(findAddBtn().text()).toBe(i18n.addButton);
    });

    it('opens the modal', () => {
      findAddBtn().trigger('click');
      expect(glModalDirective).toHaveBeenCalled();
    });
  });

  describe('Modal', () => {
    it('sets the modals props', () => {
      expect(findModal().props()).toMatchObject({
        actionPrimary: { text: i18n.title, attributes: [{ variant: 'confirm' }] },
        actionCancel: { text: i18n.cancelButton },
        modalId,
        size: 'sm',
        title: i18n.title,
      });
    });
  });
});
