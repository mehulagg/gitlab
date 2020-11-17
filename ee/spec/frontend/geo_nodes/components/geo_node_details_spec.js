import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';

import geoNodeDetailsComponent from 'ee/geo_nodes/components/geo_node_details.vue';
import { mockNode, mockNodeDetails } from '../mock_data';

describe('GeoNodeDetailsComponent', () => {
  let wrapper;

  const defaultProps = {
    node: mockNode,
    nodeDetails: mockNodeDetails,
    nodeActionsAllowed: true,
    nodeEditAllowed: true,
    nodeRemovalAllowed: true,
    geoTroubleshootingHelpPath: '/foo/bar',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(geoNodeDetailsComponent, {
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

  const findErrorSection = () => wrapper.find('[data-testid="errorSection"]');
  const findTroubleshootingLink = () => findErrorSection().find(GlLink);

  describe('template', () => {
    it('renders container elements correctly', () => {
      expect(wrapper.classes('card-body')).toBe(true);
    });

    describe('when unhealthy', () => {
      describe('with errorMessage', () => {
        beforeEach(() => {
          createComponent({
            nodeDetails: {
              ...defaultProps.nodeDetails,
              healthy: false,
              health: 'This is an error',
            },
          });
        });

        it('renders error message section', () => {
          expect(findErrorSection().text()).toContain('This is an error');
        });

        it('renders troubleshooting URL within error message section', () => {
          expect(findTroubleshootingLink().attributes('href')).toBe('/foo/bar');
        });
      });

      describe('without error message', () => {
        beforeEach(() => {
          createComponent({
            nodeDetails: {
              ...defaultProps.nodeDetails,
              healthy: false,
              health: '',
            },
          });
        });

        it('does not render error message section', () => {
          expect(findErrorSection().exists()).toBe(false);
        });
      });
    });

    describe('when healthy', () => {
      beforeEach(() => {
        createComponent();
      });

      it('does not render error message section', () => {
        expect(findErrorSection().exists()).toBe(false);
      });
    });

    describe('when version mismatched', () => {
      describe('when node is primary', () => {
        beforeEach(() => {
          createComponent({
            node: {
              ...defaultProps.node,
              primary: true,
            },
            nodeDetails: {
              ...defaultProps.nodeDetails,
              primaryVersion: '10.3.0-pre',
              primaryRevision: 'b93c51850b',
            },
          });
        });

        it('does not render error message section', () => {
          expect(findErrorSection().exists()).toBe(false);
        });
      });

      describe('when node is secondary', () => {
        beforeEach(() => {
          createComponent({
            node: {
              ...defaultProps.node,
              primary: false,
            },
            nodeDetails: {
              ...defaultProps.nodeDetails,
              primaryVersion: '10.3.0-pre',
              primaryRevision: 'b93c51850b',
            },
          });
        });

        it('renders error message section', () => {
          expect(findErrorSection().text()).toContain(
            'GitLab version does not match the primary node version',
          );
        });

        it('renders troubleshooting URL within error message section', () => {
          expect(findTroubleshootingLink().attributes('href')).toBe('/foo/bar');
        });
      });
    });
  });
});
