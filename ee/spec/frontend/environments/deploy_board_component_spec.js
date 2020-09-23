import Vue from 'vue';
import { mount } from '@vue/test-utils';
import DeployBoard from 'ee/environments/components/deploy_board_component.vue';
import { deployBoardMockData, environment } from './mock_data';

const logsPath = `gitlab-org/gitlab-test/-/logs?environment_name=${environment.name}`;

describe('Deploy Board', () => {
  let wrapper;

  const createComponent = (props = {}) =>
    mount(Vue.extend(DeployBoard), {
      propsData: {
        deployBoardData: deployBoardMockData,
        isLoading: false,
        isEmpty: false,
        logsPath,
        ...props,
      },
    });

  describe('with valid data', () => {
    beforeEach(done => {
      wrapper = createComponent();
      wrapper.vm.$nextTick(done);
    });

    it('should render percentage with completion value provided', () => {
      expect(wrapper.vm.$refs.percentage.innerText).toEqual(`${deployBoardMockData.completion}%`);
    });

    it('should render total instance count', () => {
      const renderedTotal = wrapper.find('.deploy-board-instances-text');
      const actualTotal = deployBoardMockData.instances.length;
      const output = `${actualTotal > 1 ? 'Instances' : 'Instance'} (${actualTotal})`;

      expect(renderedTotal.text()).toEqual(output);
    });

    it('should render all instances', () => {
      const instances = wrapper.findAll('.deploy-board-instances-container a');

      expect(instances).toHaveLength(deployBoardMockData.instances.length);
      expect(
        instances.at(1).classes(`deployment-instance-${deployBoardMockData.instances[2].status}`),
      ).toBe(true);
    });

    it('should render an abort and a rollback button with the provided url', () => {
      const buttons = wrapper.findAll('.deploy-board-actions a');

      expect(buttons.at(0).attributes('href')).toEqual(deployBoardMockData.rollback_url);
      expect(buttons.at(1).attributes('href')).toEqual(deployBoardMockData.abort_url);
    });
  });

  describe('with empty state', () => {
    beforeEach(done => {
      wrapper = createComponent({
        deployBoardData: {},
        isLoading: false,
        isEmpty: true,
        logsPath,
      });
      wrapper.vm.$nextTick(done);
    });

    it('should render the empty state', () => {
      expect(wrapper.find('.deploy-board-empty-state-svg svg')).toBeDefined();
      expect(
        wrapper.find('.deploy-board-empty-state-text .deploy-board-empty-state-title').text(),
      ).toContain('Kubernetes deployment not found');
    });
  });

  describe('with loading state', () => {
    beforeEach(done => {
      wrapper = createComponent({
        deployBoardData: {},
        isLoading: true,
        isEmpty: false,
        logsPath,
      });
      wrapper.vm.$nextTick(done);
    });

    it('should render loading spinner', () => {
      expect(wrapper.find('.fa-spin')).toBeDefined();
    });
  });

  describe('with hasLegacyAppLabel equal true', () => {
    beforeEach(done => {
      wrapper = createComponent({
        isLoading: false,
        isEmpty: false,
        logsPath,
        hasLegacyAppLabel: true,
        deployBoardData: {},
      });
      wrapper.vm.$nextTick(done);
    });

    it('should render legacy label warning message', () => {
      const warningMessage = wrapper.find('.bs-callout-warning');

      expect(warningMessage).toBeTruthy();
      expect(warningMessage.text()).toContain(
        'Matching on the app label has been removed for deploy boards.',
      );
    });
  });

  describe('has legend component', () => {
    let statuses = [];
    beforeEach(done => {
      wrapper = createComponent({
        isLoading: false,
        isEmpty: false,
        logsPath: environment.log_path,
        hasLegacyAppLabel: true,
        deployBoardData: deployBoardMockData,
      });
      ({ statuses } = wrapper.vm);
      wrapper.vm.$nextTick(done);
    });

    it('with all the possible statuses', () => {
      const deployBoardLegend = wrapper.find('.deploy-board-legend');

      expect(deployBoardLegend).toBeDefined();
      expect(deployBoardLegend.findAll('a')).toHaveLength(Object.keys(statuses).length);
    });

    Object.keys(statuses).forEach(item => {
      it(`with ${item} text next to deployment instance icon`, () => {
        expect(wrapper.find(`.deployment-instance-${item}`)).toBeDefined();
        expect(wrapper.find(`.deployment-instance-${item} + .legend-text`).text()).toBe(
          statuses[item].text,
        );
      });
    });
  });
});
