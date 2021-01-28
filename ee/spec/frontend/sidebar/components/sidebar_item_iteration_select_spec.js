import { shallowMount } from '@vue/test-utils';
import { GlLink, GlButton, GlDropdown } from '@gitlab/ui';

import SidebarItemIterationSelect from 'ee/sidebar/components/sidebar_item_iteration_select.vue';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';

describe('SidebarItemIterationSelect', () => {
  let wrapper;

  const createComponent = ({
    data = { editing: false, currentIteration: null },
    props = { canEdit: true },
    stubs = {},
  } = {}) => {
    wrapper = shallowMount(SidebarItemIterationSelect, {
      data: () => data,
      stubs,
      propsData: {
        ...props,
        groupPath: '',
        projectPath: '',
        issueIid: '',
      },
      attachTo: document.body,
    });
  };

  const findSelectedIteration = () => wrapper.find('[data-testid="select-iteration"]');
  const findGlLink = () => wrapper.find(GlLink);
  const findEditButton = () => wrapper.find(GlButton);
  const findDropdown = () => wrapper.find(GlDropdown);
  const findIterationTitle = () => wrapper.find('[data-testid="iteration-title"]');
  const findIterationSelect = () => wrapper.find(IterationSelect);

  let editButton;

  const clickEditButton = async (spy = () => {}) => {
    editButton.vm.$emit('click', { stopPropagation: spy });
    await wrapper.vm.$nextTick();
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when not editing', () => {
    it('shows the current iteration', () => {
      createComponent({
        data: {
          editing: false,
          currentIteration: { id: 'id', title: 'title' },
        },
      });

      expect(findSelectedIteration().text()).toBe('title');
    });

    it('links to the current iteration', () => {
      createComponent({
        data: {
          editing: false,
          currentIteration: { id: 'id', title: 'title', webUrl: 'webUrl' },
        },
      });

      expect(findGlLink().attributes().href).toBe('webUrl');
    });
  });

  describe('when no iteration is assigned to the issue', () => {
    it('shows "None" as title and should not have a link', () => {
      createComponent({
        data: {
          editing: false,
          currentIteration: null,
        },
      });

      expect(findSelectedIteration().text()).toBe('None');
      expect(findGlLink().exists()).toBe(false);
    });
  });

  describe('when a user cannot edit', () => {
    it('cannot find the edit button', () => {
      createComponent({ props: { canEdit: false } });

      expect(findEditButton().exists()).toBe(false);
    });
  });

  describe('when a user can edit', () => {
    beforeEach(() => {
      createComponent({
        props: { canEdit: true },
        stubs: { IterationSelect },
      });
      jest.spyOn(findIterationSelect().vm, 'setFocus').mockImplementation();
      jest.spyOn(findIterationSelect().vm, 'showDropdown').mockImplementation();
      editButton = findEditButton();
    });

    it('opens the dropdown when the edit button is clicked', async () => {
      expect(editButton.exists()).toBe(true);
      expect(findDropdown().exists()).toBe(false);

      await clickEditButton();

      expect(findDropdown().isVisible()).toBe(true);
    });

    describe('when the dropdown is open', () => {
      beforeEach(async () => {
        await clickEditButton();
      });

      it('closes the dropdown when the edit button is clicked again', async () => {
        expect(findDropdown().isVisible()).toBe(true);

        await clickEditButton();

        expect(findDropdown().exists()).toBe(false);
      });

      it('closes the dropdown when the user off clicks', async () => {
        expect(findDropdown().isVisible()).toBe(true);

        await findIterationTitle().trigger('click');

        expect(findDropdown().exists()).toBe(false);
      });

      it('should not close the dropdown when the user clicks inside the dropdown', async () => {
        expect(findDropdown().isVisible()).toBe(true);

        await findIterationSelect().trigger('click');

        expect(findDropdown().isVisible()).toBe(true);
      });
    });

    it('stops propagation of the click event to avoid opening milestone dropdown', async () => {
      const spy = jest.fn();
      await clickEditButton(spy);

      expect(spy).toHaveBeenCalledTimes(1);
    });

    describe('when the iteration for the issue is updated', () => {
      it('updates iteration title and url', async () => {
        await clickEditButton();

        findIterationSelect().vm.$emit('iterationUpdate', {
          id: '1',
          title: 'iteration 1',
          webUrl: 'foo',
        });
        findIterationSelect().vm.$emit('dropdownClose');

        await wrapper.vm.$nextTick();

        expect(findIterationTitle().text()).toBe('iteration 1');
        expect(findGlLink().attributes().href).toBe('foo');
      });
    });
  });
});
