import { GlSkeletonLoader } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionDetailsTable from 'ee/pages/admin/cloud_licenses/components/subscription_details_table.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const licenseDetails = [
  {
    label: 'Row label 1',
    value: 'row content 1',
  },
  {
    label: 'Row label 2',
    value: 'row content 2',
  },
];

const hasFontWeightBold = (wrapper) => wrapper.classes('gl-font-weight-bold');

describe('Subscription Details Table', () => {
  let wrapper;

  const findLabelCells = () => wrapper.findAllByTestId('details-label');
  const findContentCells = () => wrapper.findAllByTestId('details-content');
  const findLastRow = () => wrapper.findAll('li').wrappers.reverse().slice(0, 1).pop();

  const createComponent = (details = licenseDetails) => {
    wrapper = extendedWrapper(shallowMount(SubscriptionDetailsTable, { propsData: { details } }));
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with content', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays the correct number of rows', () => {
      expect(findLabelCells()).toHaveLength(2);
      expect(findContentCells()).toHaveLength(2);
    });

    it('displays the correct content for rows', () => {
      expect(findLabelCells().at(0).text()).toBe('Row label 1:');
      expect(findContentCells().at(0).text()).toBe('row content 1');
    });

    it('displays the labels in bold', () => {
      expect(findLabelCells().wrappers.every(hasFontWeightBold)).toBe(true);
    });

    it('does not add space to the last row', () => {
      expect(findLastRow().classes('gl-mb-3')).toBe(false);
    });
  });

  describe('with no content', () => {
    it('displays a loader', () => {
      createComponent([]);

      expect(wrapper.find(GlSkeletonLoader).exists()).toBe(true);
    });
  });
});
