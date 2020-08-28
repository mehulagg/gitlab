import { mount } from '@vue/test-utils';

describe('Custom jest matchers', () => {
  describe('toMatchInterpolatedText', () => {
    describe('malformed input', () => {
      it.each([null, 1, Symbol, Array, Object])(
        'fails graciously if the expected value is %s',
        expected => {
          expect(expected).not.toMatchInterpolatedText('null');
        },
      );
    });
    describe('malformed matcher', () => {
      it.each([null, 1, Symbol, Array, Object])(
        'fails graciously if the matcher is %s',
        matcher => {
          expect('null').not.toMatchInterpolatedText(matcher);
        },
      );
    });

    describe('positive assertion', () => {
      it.each`
        htmlString         | templateString
        ${'foo'}           | ${'foo'}
        ${'foo'}           | ${'foo%{foo}'}
        ${'foo  '}         | ${'foo'}
        ${'foo  '}         | ${'foo%{foo}'}
        ${'foo   . '}      | ${'foo%{foo}.'}
        ${'foo   bar . '}  | ${'foo%{foo} bar.'}
        ${'foo\n\nbar . '} | ${'foo%{foo} bar.'}
        ${'foo bar . .'}   | ${'foo%{fooStart} bar.%{fooEnd}.'}
      `('$htmlString equals $templateString', ({ htmlString, templateString }) => {
        expect(htmlString).toMatchInterpolatedText(templateString);
      });
    });

    describe('negative assertion', () => {
      it.each`
        htmlString  | templateString
        ${'foo'}    | ${'bar'}
        ${'foo'}    | ${'bar%{foo}'}
        ${'foo'}    | ${'@{lol}foo%{foo}'}
        ${' fo o '} | ${'foo'}
      `('$htmlString does not equal $templateString', ({ htmlString, templateString }) => {
        expect(htmlString).not.toMatchInterpolatedText(templateString);
      });
    });
  });

  describe('toBeVueInstanceOf', () => {
    const DemoComponent1 = { template: '<div>comp1</div>' };
    const DemoComponent2 = { template: '<div>comp2</div>' };
    let wrapper;

    beforeEach(() => {
      wrapper = mount(DemoComponent1);
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('positive assertion', () => {
      expect(wrapper).toBeVueInstanceOf(DemoComponent1);
    });

    it('negative assertion', () => {
      expect(wrapper).not.toBeVueInstanceOf(DemoComponent2);
    });
  });
});
