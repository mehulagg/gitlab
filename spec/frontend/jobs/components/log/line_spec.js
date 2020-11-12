import { shallowMount } from '@vue/test-utils';
import Line from '~/jobs/components/log/line.vue';
import LineNumber from '~/jobs/components/log/line_number.vue';

const httpUrl = 'http://example.com';
const httpsUrl = 'https://example.com';

const mockProps = ({ text = 'Running with gitlab-runner 12.1.0 (de7731dd)' } = {}) => ({
  line: {
    content: [
      {
        text,
        style: 'term-fg-l-green',
      },
    ],
    lineNumber: 0,
  },
  path: '/jashkenas/underscore/-/jobs/335',
});

describe('Job Log Line', () => {
  let wrapper;
  let data;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(Line, {
      propsData: {
        ...props,
      },
    });
  };

  const findLine = () => wrapper.find('span');
  const findLink = () => findLine().find('a');
  const findLinksAt = i =>
    findLine()
      .findAll('a')
      .at(i);

  beforeEach(() => {
    data = mockProps();
    createComponent(data);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the line number component', () => {
    expect(wrapper.find(LineNumber).exists()).toBe(true);
  });

  it('renders a span the provided text', () => {
    expect(findLine().text()).toBe(data.line.content[0].text);
  });

  it('renders the provided style as a class attribute', () => {
    expect(findLine().classes()).toContain(data.line.content[0].style);
  });

  describe('when the line contains a link', () => {
    it('renders an http link', () => {
      createComponent(mockProps({ text: httpUrl }));

      expect(findLink().text()).toBe(httpUrl);
      expect(findLink().attributes().href).toEqual(httpUrl);
    });

    it('renders an https link', () => {
      createComponent(mockProps({ text: httpsUrl }));

      expect(findLink().text()).toBe(httpsUrl);
      expect(findLink().attributes().href).toEqual(httpsUrl);
    });

    it('renders a multiple links surrounded by text', () => {
      createComponent(mockProps({ text: `My HTTP url: ${httpUrl} and my HTTPS url: ${httpsUrl}` }));
      expect(findLine().text()).toBe(
        'My HTTP url: http://example.com and my HTTPS url: https://example.com',
      );
      expect(findLinksAt(0).attributes().href).toEqual(httpUrl);
      expect(findLinksAt(1).attributes().href).toEqual(httpsUrl);
    });

    it('renders a link with rel nofollow and noopener', () => {
      createComponent(mockProps({ text: httpsUrl }));

      expect(findLink().attributes().rel).toBe('nofollow noopener');
    });

    it('does not render links', () => {
      createComponent(
        mockProps({ text: `My HTTP url: ${httpUrl} and my HTTPS url: ${httpsUrl} are here.` }),
      );
      expect(findLine().text()).toBe(
        'My HTTP url: http://example.com and my HTTPS url: https://example.com are here.',
      );
      expect(findLinksAt(0).attributes().href).toEqual(httpUrl);
      expect(findLinksAt(1).attributes().href).toEqual(httpsUrl);
    });

    it.each([
      'javascript:doevil();', // eslint-disable-line no-script-url
      'gitlab.com',
      'about.gitlab.com',
      'file:///a-file',
      'alice@example.com',
    ])('does not render disabled links', () => {
      expect(findLink().exists()).toBe(false);
    });

    test.each`
      type           | text
      ${'ftp'}       | ${'ftp://example.com/file'}
      ${'email'}     | ${'email@example.com'}
      ${'no scheme'} | ${'example.com/page'}
    `('does not render a $type link', ({ text }) => {
      createComponent(mockProps({ text }));
      expect(findLink().exists()).toBe(false);
    });
  });
});
