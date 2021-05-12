import { GlButton, GlModal } from '@gitlab/ui';
import ModalUpdate, { i18n } from 'ee/status_checks/components/modal_update.vue';
import { stubComponent } from 'helpers/stub_component';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

const statusCheck = {
  externalUrl: 'https://foo.com',
  id: 1,
  name: 'Foo',
  protectedBranches: [],
};
const modalId = `status-checks-edit-modal-${statusCheck.id}`;

describe('Modal update', () => {
  let wrapper;
  const glModalDirective = jest.fn();

  const createWrapper = () => {
    wrapper = shallowMountExtended(ModalUpdate, {
      directives: {
        glModal: {
          bind(el, { modifiers }) {
            glModalDirective(modifiers);
          },
        },
      },
      propsData: {
        statusCheck,
      },
      stubs: {
        GlButton: stubComponent(GlButton, {
          props: ['v-gl-modal'],
        }),
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findEditBtn = () => wrapper.findByTestId('edit-btn');
  const findModal = () => wrapper.findComponent(GlModal);

  describe('Edit button', () => {
    it('renders', () => {
      expect(findEditBtn().text()).toBe(i18n.editButton);
    });

    it('opens the modal', () => {
      findEditBtn().trigger('click');
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
