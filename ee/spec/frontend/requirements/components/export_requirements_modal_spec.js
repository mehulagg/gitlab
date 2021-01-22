import { shallowMount } from '@vue/test-utils';

import { GlModal } from '@gitlab/ui';

import ExportRequirementsModal from 'ee/requirements/components/export_requirements_modal.vue';

const createComponent = ({ requirementCount = 42, email = 'admin@example.com' } = {}) =>
  shallowMount(ExportRequirementsModal, {
    propsData: {
      requirementCount,
      email,
    },
  });

describe('ExportRequirementsModal', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('handleExport', () => {
      it('emits `export` event', () => {
        wrapper.vm.handleExport();

        const emitted = wrapper.emitted('export');

        expect(emitted).toBeDefined();
      });
    });
  });

  describe('template', () => {
    it('GlModal open click emits export event', () => {
      wrapper.find(GlModal).vm.$emit('ok');

      const emitted = wrapper.emitted('export');

      expect(emitted).toBeDefined();
    });
  });
});
