import { GlLoadingIcon, GlButton, GlSprintf } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import DevopsAdoptionEmptyState from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_empty_state.vue';
import DevopsAdoptionSection from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_section.vue';
import DevopsAdoptionTable from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_table.vue';
import { DEVOPS_ADOPTION_TABLE_CONFIGURATION } from 'ee/analytics/devops_report/devops_adoption/constants';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { devopsAdoptionNamespaceData } from '../mock_data';

describe('DevopsAdoptionSection', () => {
  let wrapper;

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(DevopsAdoptionSection, {
        propsData: {
          isLoading: false,
          hasSegmentsData: true,
          timestamp: '2020-10-31 23:59',
          hasGroupData: true,
          segmentLimitReached: false,
          editGroupsButtonLabel: 'Add/Remove groups',
          cols: DEVOPS_ADOPTION_TABLE_CONFIGURATION[0].cols,
          segments: devopsAdoptionNamespaceData,
          addSegmentButtonTooltipText: 'Maximum 30 groups allowed',
          ...props,
        },
        directives: {
          GlTooltip: createMockDirective(),
        },
        stubs: {
          GlSprintf,
        },
      }),
    );
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findTableHeaderSection = () => wrapper.findByTestId('tableHeader');
  const findTable = () => wrapper.findComponent(DevopsAdoptionTable);
  const findEmptyState = () => wrapper.findComponent(DevopsAdoptionEmptyState);
  const findAddEditButton = () => wrapper.findComponent(GlButton);
  const findAddRemoveButtonWrapper = () => wrapper.findByTestId('segmentButtonWrapper');

  describe('while loading', () => {
    beforeEach(() => {
      createComponent({ isLoading: true });
    });

    it('displays a loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not display the table header section', () => {
      expect(findTableHeaderSection().exists()).toBe(false);
    });

    it('does not display the table', () => {
      expect(findTable().exists()).toBe(false);
    });
  });

  describe('with segment data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('does not display a loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('does not display an empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('displays the table header section', () => {
      expect(findTableHeaderSection().exists()).toBe(true);
    });

    it('displays the table', () => {
      expect(findTableHeaderSection().exists()).toBe(true);
    });
  });

  describe('with no segment data', () => {
    beforeEach(() => {
      createComponent({ hasSegmentsData: false });
    });

    it('displays an empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });
  });

  describe('table header section', () => {
    it('displays the header message with timestamp', () => {
      createComponent();

      const text =
        'Feature adoption is based on usage in the current calendar month. Last updated: 2020-10-31 23:59.';
      expect(getByText(wrapper.element, text)).not.toBeNull();
    });

    describe('with group data', () => {
      it('displays the edit groups button', () => {
        createComponent();

        expect(findAddEditButton().exists()).toBe(true);
      });

      describe('edit groups button', () => {
        describe('segment limit reached', () => {
          beforeEach(() => {
            createComponent({ segmentLimitReached: true });
          });

          it('is disabled', () => {
            expect(findAddEditButton().props('disabled')).toBe(true);
          });

          it('displays a tooltip', () => {
            const tooltip = getBinding(findAddRemoveButtonWrapper().element, 'gl-tooltip');

            expect(tooltip).toBeDefined();
            expect(tooltip.value).toBe('Maximum 30 groups allowed');
          });
        });

        describe('segment limit not reached', () => {
          beforeEach(() => {
            createComponent();
          });

          it('is enabled', () => {
            expect(findAddEditButton().props('disabled')).toBe(false);
          });

          it('does not display a tooltip', () => {
            const tooltip = getBinding(findAddRemoveButtonWrapper().element, 'gl-tooltip');

            expect(tooltip.value).toBe(false);
          });

          it('emits openAddRemoveModal when clicked', () => {
            expect(wrapper.emitted('openAddRemoveModal')).toBeUndefined();

            findAddEditButton().vm.$emit('click');

            expect(wrapper.emitted('openAddRemoveModal')).toEqual([[]]);
          });
        });
      });
    });

    describe('with no group data', () => {
      beforeEach(() => {
        createComponent({ hasGroupData: false });
      });

      it('does not display the edit groups button', () => {
        expect(findAddEditButton().exists()).toBe(false);
      });
    });
  });
});
