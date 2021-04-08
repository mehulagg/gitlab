import { GlSkeletonLoader } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import SubscriptionDetailsTable from 'ee/pages/admin/cloud_licenses/components/subscription_details_table.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

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

  const findContentCells = () => wrapper.findAllByTestId('details-content');
  const findLabelCells = () => wrapper.findAllByTestId('details-label');
  const findClipboardButton = () => wrapper.findComponent(ClipboardButton);

  const createComponent = (details = licenseDetails) => {
    wrapper = extendedWrapper(mount(SubscriptionDetailsTable, { propsData: { details } }));
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

    it('does not show a clipboard button', () => {
      expect(findClipboardButton().exists()).toBe(false);
    });
  });

  describe('with copy-able detail', () => {
    beforeEach(() => {
      createComponent([
        {
          value: 'Something to copy',
          canCopy: true,
        },
      ]);
    });

    it('shows a clipboard button', () => {
      expect(findClipboardButton().exists()).toBe(true);
    });

    it('passes the text to the clipboard', () => {
      expect(findClipboardButton().props('text')).toBe('Something to copy');
    });
  });

  describe('with no content', () => {
    it('displays a loader', () => {
      createComponent([]);

      expect(wrapper.find(GlSkeletonLoader).exists()).toBe(true);
    });
  });
});
