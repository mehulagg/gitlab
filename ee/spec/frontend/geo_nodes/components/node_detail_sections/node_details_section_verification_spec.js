import { GlPopover, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import GeoNodeDetailItem from 'ee/geo_nodes/components/geo_node_detail_item.vue';
import NodeDetailsSectionVerificationComponent from 'ee/geo_nodes/components/node_detail_sections/node_details_section_verification.vue';
import SectionRevealButton from 'ee/geo_nodes/components/node_detail_sections/section_reveal_button.vue';

import { mockNodeDetails } from '../../mock_data';

describe('NodeDetailsSectionVerification', () => {
  let wrapper;

  const defaultProps = {
    nodeDetails: mockNodeDetails,
    nodeTypePrimary: false,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(NodeDetailsSectionVerificationComponent, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlPopover = () => wrapper.find(GlPopover);
  const findDetailItems = () => wrapper.findAll(GeoNodeDetailItem);

  describe('data', () => {
    it('returns default data props', () => {
      expect(wrapper.vm.showSectionItems).toBe(false);
    });
  });

  describe('computed', () => {
    describe('nodeText', () => {
      describe('on Primary node', () => {
        beforeEach(() => {
          createComponent({ nodeTypePrimary: true });
        });

        it('returns text about secondary nodes', () => {
          expect(wrapper.vm.nodeText).toBe('secondary nodes');
        });
      });

      describe('on Secondary node', () => {
        beforeEach(() => {
          createComponent();
        });

        it('returns text about secondary nodes', () => {
          expect(wrapper.vm.nodeText).toBe('primary node');
        });
      });
    });
  });

  describe('methods', () => {
    describe.each`
      primaryNode | dataKey           | nodeDetailItem
      ${true}     | ${'checksum'}     | ${{ itemValue: { checksumSuccessCount: 20, checksumFailureCount: 10, verificationSuccessCount: 30, verificationFailureCount: 15 } }}
      ${false}    | ${'verification'} | ${{ itemValue: { totalCount: 100, checksumSuccessCount: 20, checksumFailureCount: 10, verificationSuccessCount: 30, verificationFailureCount: 15 } }}
    `(`itemValue`, ({ primaryNode, dataKey, nodeDetailItem }) => {
      describe(`when node is ${primaryNode ? 'primary' : 'secondary'}`, () => {
        let itemValue = {};

        beforeEach(() => {
          createComponent({ nodeTypePrimary: primaryNode });
          itemValue = wrapper.vm.itemValue(nodeDetailItem);
        });

        it(`gets successCount correctly`, () => {
          expect(itemValue.successCount).toBe(nodeDetailItem.itemValue[`${dataKey}SuccessCount`]);
        });

        it(`gets failureCount correctly`, () => {
          expect(itemValue.failureCount).toBe(nodeDetailItem.itemValue[`${dataKey}FailureCount`]);
        });
      });
    });

    describe.each`
      primaryNode | itemTitle | titlePostfix
      ${true}     | ${'test'} | ${'checksum progress'}
      ${false}    | ${'test'} | ${'verification progress'}
    `(`itemTitle`, ({ primaryNode, itemTitle, titlePostfix }) => {
      describe(`when node is ${primaryNode ? 'primary' : 'secondary'}`, () => {
        let title = '';

        beforeEach(() => {
          createComponent({ nodeTypePrimary: primaryNode });
          title = wrapper.vm.itemTitle({ itemTitle });
        });

        it(`creates full title correctly`, () => {
          expect(title).toBe(`${itemTitle} ${titlePostfix}`);
        });
      });
    });
  });

  describe('template', () => {
    it('renders component container element', () => {
      expect(wrapper.vm.$el.classList.contains('verification-section')).toBe(true);
    });

    it('renders show section button element', () => {
      expect(wrapper.find(SectionRevealButton).exists()).toBeTruthy();
      expect(wrapper.find(SectionRevealButton).attributes('buttontitle')).toBe(
        'Verification information',
      );
    });

    it('renders section items container element', () => {
      wrapper.vm.showSectionItems = true;
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.$el.querySelector('.section-items-container')).not.toBeNull();
      });
    });

    describe('GlPopover', () => {
      it('renders always', () => {
        expect(findGlPopover().exists()).toBeTruthy();
      });

      it('contains text about Replicated data', () => {
        expect(
          findGlPopover()
            .find(GlSprintf)
            .attributes('message'),
        ).toContain('Replicated data is verified');
      });
    });

    describe('GeoNodeDetailItems', () => {
      describe('on Primary node', () => {
        beforeEach(() => {
          createComponent({ nodeTypePrimary: true });
          wrapper.vm.showSectionItems = true;
        });

        it('renders the checksum data', () => {
          expect(findDetailItems()).toHaveLength(mockNodeDetails.checksumStatuses.length);
        });
      });

      describe('on Secondary node', () => {
        beforeEach(() => {
          createComponent({ nodeTypePrimary: false });
          wrapper.vm.showSectionItems = true;
        });

        it('renders the verification data', () => {
          expect(findDetailItems()).toHaveLength(mockNodeDetails.verificationStatuses.length);
        });
      });
    });
  });
});
