import { GlDropdown } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import StageComponent from '~/pipelines/components/pipelines_list/stage.vue';
import eventHub from '~/pipelines/event_hub';
import { stageReply } from './mock_data';

describe('Pipelines stage component', () => {
  let wrapper;
  let mock;
  let glFeatures;

  const defaultProps = {
    stage: {
      status: {
        group: 'success',
        icon: 'status_success',
        title: 'success',
      },
      dropdown_path: 'path.json',
    },
    updateDropdown: false,
  };

  const createComponent = (props = {}) => {
    wrapper = mount(StageComponent, {
      attachTo: document.body,
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        glFeatures,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    jest.spyOn(eventHub, '$emit');
    glFeatures = {};
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;

    eventHub.$emit.mockRestore();
    mock.restore();
  });

  const findDropdown = () => wrapper.find(GlDropdown);
  const findDropdownToggle = () => wrapper.find('button.gl-dropdown-toggle');
  const findDropdownMenu = () =>
    wrapper.find('[data-testid="mini-pipeline-graph-dropdown-menu-list"]');
  const findCiActionBtn = () => wrapper.find('.js-ci-action');

  const openGlDropdown = () => {
    findDropdownToggle().trigger('click');
    return new Promise((resolve) => {
      wrapper.vm.$root.$on('bv::dropdown::show', resolve);
    });
  };

  beforeEach(() => {
    glFeatures = { ciMiniPipelineGlDropdown: true };
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should render a dropdown with the status icon', () => {
      expect(findDropdown().exists()).toBe(true);
      expect(findDropdownToggle().classes('gl-dropdown-toggle')).toEqual(true);
      expect(wrapper.find('[data-testid="status_success_borderless-icon"]').exists()).toBe(true);
    });
  });

  describe('with successful request', () => {
    beforeEach(() => {
      mock.onGet('path.json').reply(200, stageReply);
      createComponent();
    });

    it('should render the received data and emit `clickedDropdown` event', async () => {
      await openGlDropdown();
      await axios.waitForAll();

      expect(findDropdownMenu().text()).toContain(stageReply.latest_statuses[0].name);
      expect(eventHub.$emit).toHaveBeenCalledWith('clickedDropdown');
    });
  });

  it('when request fails should close the dropdown', async () => {
    mock.onGet('path.json').reply(500);

    createComponent();

    await openGlDropdown();
    await axios.waitForAll();

    expect(findDropdown().classes('show')).toBe(false);
  });

  describe('update endpoint correctly', () => {
    beforeEach(async () => {
      const copyStage = { ...stageReply };
      copyStage.latest_statuses[0].name = 'this is the updated content';
      mock.onGet('bar.json').reply(200, copyStage);
      createComponent({
        stage: {
          status: {
            group: 'running',
            icon: 'status_running',
            title: 'running',
          },
          dropdown_path: 'bar.json',
        },
      });
      await axios.waitForAll();
    });

    it('should update the stage to request the new endpoint provided', async () => {
      await openGlDropdown();
      await axios.waitForAll();

      expect(findDropdownMenu().text()).toContain('this is the updated content');
    });
  });

  describe('pipelineActionRequestComplete', () => {
    beforeEach(() => {
      mock.onGet('path.json').reply(200, stageReply);
      mock.onPost(`${stageReply.latest_statuses[0].status.action.path}.json`).reply(200);

      createComponent();
    });

    const clickCiAction = async () => {
      await openGlDropdown();
      await axios.waitForAll();

      findCiActionBtn().trigger('click');
      await axios.waitForAll();
    };

    it('closes the dropdown when `pipelineActionRequestComplete` is triggered', async () => {
      const hidden = jest.fn();

      wrapper.vm.$root.$on('bv::dropdown::hide', hidden);

      expect(hidden).toHaveBeenCalledTimes(0);

      await clickCiAction();

      expect(hidden).toHaveBeenCalledTimes(1);
      expect(wrapper.emitted('pipelineActionRequestComplete')).toHaveLength(1);
    });
  });
});
