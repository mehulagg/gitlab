import $ from 'jquery';
import { escape } from 'lodash';
import { mount } from '@vue/test-utils';
import tooltip from '~/vue_shared/directives/tooltip';

const DEFAULT_TOOLTIP_TEMPLATE = '<div v-tooltip :title="tooltip"></div>';

describe('Tooltip directive', () => {
  let wrapper;

  function createTooltipContainer({
    template = DEFAULT_TOOLTIP_TEMPLATE,
    text = 'some text',
    isHtml = false,
  } = {}) {
    wrapper = mount(
      {
        directives: { tooltip },
        data: () => ({ tooltip: text }),
        template: isHtml ? template.replace('v-tooltip', 'v-tooltip data-html=true') : template,
      },
      { attachToDocument: true },
    );
  }

  async function showTooltip() {
    $(wrapper.vm.$el).tooltip('show');
    jest.runOnlyPendingTimers();
    await wrapper.vm.$nextTick();
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with a single tooltip', () => {
    it('should have tooltip plugin applied', () => {
      createTooltipContainer();

      expect($(wrapper.vm.$el).data('bs.tooltip')).toBeDefined();
    });

    it('displays the title as tooltip', () => {
      createTooltipContainer();

      $(wrapper.vm.$el).tooltip('show');

      jest.runOnlyPendingTimers();

      const tooltipElement = document.querySelector('.tooltip-inner');

      expect(tooltipElement.textContent).toContain('some text');
    });

    it.each`
      condition                      | isHtml   | sanitize
      ${'does not contain any html'} | ${false} | ${false}
      ${'contains html'}             | ${true}  | ${true}
    `('passes sanitize=$sanitize if the tooltip $condition', ({ isHtml, sanitize }) => {
      createTooltipContainer({ isHtml });

      expect($(wrapper.vm.$el).data('bs.tooltip').config.sanitize).toEqual(sanitize);
    });

    it('updates a visible tooltip', async () => {
      createTooltipContainer();

      $(wrapper.vm.$el).tooltip('show');
      jest.runOnlyPendingTimers();

      const tooltipElement = document.querySelector('.tooltip-inner');

      wrapper.vm.tooltip = 'other text';

      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();

      expect(tooltipElement.textContent).toContain('other text');
    });

    describe('tooltip sanitization', () => {
      it('reads tooltip content as text if data-html is not passed', async () => {
        createTooltipContainer({ text: 'sample text<script>alert("XSS!!")</script>' });

        await showTooltip();

        const tooltipElement = document.querySelector('.tooltip-inner');
        expect(tooltipElement.innerHTML).toEqual(
          'sample text&lt;script&gt;alert("XSS!!")&lt;/script&gt;',
        );
      });

      it('sanitizes tooltip if data-html is passed', async () => {
        createTooltipContainer({
          isHtml: true,
          text: 'sample text<script>alert("XSS!!")</script>',
        });

        await showTooltip();

        const tooltipElement = document.querySelector('.tooltip-inner');
        expect(tooltipElement.innerHTML).toEqual('sample text');
        expect(tooltipElement.innerHTML).not.toContain('XSS!!');
      });

      it('sanitizes tooltip if data-template is passed', async () => {
        const tooltipTemplate = escape(
          '<div class="tooltip" role="tooltip"><div onclick="alert(\'XSS!\')" class="arrow"></div><div class="tooltip-inner"></div></div>',
        );

        createTooltipContainer({
          isHtml: true,
          template: `<div v-tooltip :title="tooltip" data-template="${tooltipTemplate}"></div>`,
        });

        await showTooltip();

        const tooltipElement = document.querySelector('.tooltip');
        expect(tooltipElement.innerHTML).toEqual(
          // objectionable element is removed
          '<div class="arrow"></div><div class="tooltip-inner">some text</div>',
        );
        expect(tooltipElement.innerHTML).not.toContain('XSS!!');
      });
    });
  });

  describe('with multiple tooltips', () => {
    beforeEach(() => {
      createTooltipContainer({
        template: `
          <div>
            <div
              v-tooltip
              class="js-look-for-tooltip"
              title="foo">
            </div>
            <div
              v-tooltip
              title="bar">
            </div>
          </div>
        `,
      });
    });

    it('should have tooltip plugin applied to all instances', () => {
      expect(
        $(wrapper.vm.$el)
          .find('.js-look-for-tooltip')
          .data('bs.tooltip'),
      ).toBeDefined();
    });
  });
});
