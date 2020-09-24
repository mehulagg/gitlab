import Vue from 'vue';
import LinkedPipelinesMiniList from 'ee/vue_shared/components/linked_pipelines_mini_list.vue';
import mockData from './linked_pipelines_mock_data';

const ListComponent = Vue.extend(LinkedPipelinesMiniList);

describe('Linked pipeline mini list', () => {
  let component;

  describe('when passed an upstream pipeline as prop', () => {
    beforeEach(() => {
      component = new ListComponent({
        propsData: {
          triggeredBy: [mockData.triggered_by],
        },
      }).$mount();
    });

    it('should render one linked pipeline item', () => {
      expect(component.$el.querySelectorAll('.linked-pipeline-mini-item').length).toBe(1);
    });

    it('should render a linked pipeline with the correct href', () => {
      const linkElement = component.$el.querySelector('.linked-pipeline-mini-item');

      expect(linkElement.getAttribute('href')).toBe('/gitlab-org/gitlab-foss/pipelines/129');
    });

    it('should render one ci status icon', () => {
      expect(component.$el.querySelectorAll('.linked-pipeline-mini-item svg').length).toBe(1);
    });

    it('should render the correct ci status icon', () => {
      const iconElement = component.$el.querySelector('.linked-pipeline-mini-item');

      expect(iconElement.classList.contains('ci-status-icon-running')).toBe(true);
      expect(iconElement.innerHTML).toContain('<svg');
    });

    it('should render an arrow icon', () => {
      const iconElement = component.$el.querySelector('.arrow-icon');

      expect(iconElement).not.toBeNull();
      expect(iconElement.innerHTML).toContain('long-arrow');
    });

    it('should have an activated tooltip', () => {
      const itemElement = component.$el.querySelector('.linked-pipeline-mini-item');

      expect(itemElement.getAttribute('data-original-title')).toBe('GitLabCE - running');
    });

    it('should correctly set is-upstream', () => {
      expect(component.$el.classList.contains('is-upstream')).toBe(true);
    });

    it('should correctly compute shouldRenderCounter', () => {
      expect(component.shouldRenderCounter).toBe(false);
    });

    it('should not render the pipeline counter', () => {
      expect(component.$el.querySelector('.linked-pipelines-counter')).toBeNull();
    });
  });

  describe('when passed downstream pipelines as props', () => {
    beforeEach(() => {
      component = new ListComponent({
        propsData: {
          triggered: mockData.triggered,
          pipelinePath: 'my/pipeline/path',
        },
      }).$mount();
    });

    it('should render one linked pipeline item', () => {
      expect(
        component.$el.querySelectorAll('.linked-pipeline-mini-item:not(.linked-pipelines-counter)')
          .length,
      ).toBe(3);
    });

    it('should render three ci status icons', () => {
      expect(component.$el.querySelectorAll('.linked-pipeline-mini-item svg').length).toBe(3);
    });

    it('should render the correct ci status icon', () => {
      const iconElement = component.$el.querySelector('.linked-pipeline-mini-item');

      expect(iconElement.classList.contains('ci-status-icon-running')).toBe(true);
      expect(iconElement.innerHTML).toContain('<svg');
    });

    it('should render an arrow icon', () => {
      const iconElement = component.$el.querySelector('.arrow-icon');

      expect(iconElement).not.toBeNull();
      expect(iconElement.innerHTML).toContain('long-arrow');
    });

    it('should have prepped tooltips', () => {
      const itemElement = component.$el.querySelectorAll('.linked-pipeline-mini-item')[2];

      expect(itemElement.getAttribute('data-original-title')).toBe('GitLabCE - running');
    });

    it('should correctly set is-downstream', () => {
      expect(component.$el.classList.contains('is-downstream')).toBe(true);
    });

    it('should correctly compute shouldRenderCounter', () => {
      expect(component.shouldRenderCounter).toBe(true);
    });

    it('should correctly trim linkedPipelines', () => {
      expect(component.triggered.length).toBe(6);
      expect(component.linkedPipelinesTrimmed.length).toBe(3);
    });

    it('should render the pipeline counter', () => {
      expect(component.$el.querySelector('.linked-pipelines-counter')).not.toBeNull();
    });

    it('should set the correct pipeline path', () => {
      expect(component.$el.querySelector('.linked-pipelines-counter').getAttribute('href')).toBe(
        'my/pipeline/path',
      );
    });

    it('should render the correct counterTooltipText', () => {
      expect(
        component.$el
          .querySelector('.linked-pipelines-counter')
          .getAttribute('data-original-title'),
      ).toBe(component.counterTooltipText);
    });
  });
});
