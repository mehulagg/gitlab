import { mount } from '@vue/test-utils';
import { getAllByRole, getByTestId } from '@testing-library/dom';
import { GlLink } from '@gitlab/ui';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';
import VulnerabilityDetails from 'ee/vulnerabilities/components/details.vue';

describe('Vulnerability Details', () => {
  let wrapper;

  const vulnerability = {
    title: 'some title',
    severity: 'bad severity',
    confidence: 'high confidence',
    report_type: 'nice report_type',
    description: 'vulnerability description',
  };

  const createWrapper = vulnerabilityOverrides => {
    const propsData = {
      vulnerability: { ...vulnerability, ...vulnerabilityOverrides },
    };

    wrapper = mount(VulnerabilityDetails, { propsData });
  };

  const getById = id => wrapper.find(`[data-testid="${id}"]`);
  const getAllById = id => wrapper.findAll(`[data-testid="${id}"]`);
  const getText = id => getById(id).text();

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows the properties that should always be shown', () => {
    createWrapper();
    expect(getText('title')).toBe(vulnerability.title);
    expect(getText('description')).toBe(vulnerability.description);
    expect(wrapper.find(SeverityBadge).props('severity')).toBe(vulnerability.severity);
    expect(getText('reportType')).toBe(`Report Type: ${vulnerability.report_type}`);

    expect(getById('image').exists()).toBe(false);
    expect(getById('os').exists()).toBe(false);
    expect(getById('file').exists()).toBe(false);
    expect(getById('class').exists()).toBe(false);
    expect(getById('method').exists()).toBe(false);
    expect(getById('evidence').exists()).toBe(false);
    expect(getById('scanner').exists()).toBe(false);
    expect(getAllById('link')).toHaveLength(0);
    expect(getAllById('identifier')).toHaveLength(0);
  });

  it('shows the location image if it exists', () => {
    createWrapper({ location: { image: 'some image' } });
    expect(getText('image')).toBe(`Image: some image`);
  });

  it('shows the operating system if it exists', () => {
    createWrapper({ location: { operating_system: 'linux' } });
    expect(getText('namespace')).toBe(`Namespace: linux`);
  });

  it('shows the vulnerability class if it exists', () => {
    createWrapper({ location: { file: 'file', class: 'class name' } });
    expect(getText('class')).toBe(`Class: class name`);
  });

  it('shows the vulnerability method if it exists', () => {
    createWrapper({ location: { file: 'file', method: 'method name' } });
    expect(getText('method')).toBe(`Method: method name`);
  });

  it('shows the evidence if it exists', () => {
    createWrapper({ evidence: 'some evidence' });
    expect(getText('evidence')).toBe(`Evidence: some evidence`);
  });

  it('shows the links if they exist', () => {
    createWrapper({ links: [{ url: '0' }, { url: '1' }, { url: '2' }] });
    const links = getAllById('link');
    expect(links).toHaveLength(3);

    links.wrappers.forEach((link, index) => {
      expect(link.attributes('target')).toBe('_blank');
      expect(link.attributes('href')).toBe(index.toString());
      expect(link.text()).toBe(index.toString());
    });
  });

  it('shows the vulnerability identifiers if they exist', () => {
    createWrapper({
      identifiers: [{ url: '0', name: '00' }, { url: '1', name: '11' }, { url: '2', name: '22' }],
    });

    const identifiers = getAllById('identifier');
    expect(identifiers).toHaveLength(3);

    const checkIdentifier = index => {
      const identifier = identifiers.at(index);
      expect(identifier.attributes('target')).toBe('_blank');
      expect(identifier.attributes('href')).toBe(index.toString());
      expect(identifier.text()).toBe(`${index}${index}`);
    };

    for (let i = 0; i < identifiers.length; i += 1) {
      checkIdentifier(i);
    }
  });

  describe('file link', () => {
    const file = () => getById('file').find(GlLink);

    it('shows only the file name if there is no start line', () => {
      createWrapper({ location: { file: 'test.txt', blob_path: 'blob_path.txt' } });
      expect(file().attributes('target')).toBe('_blank');
      expect(file().attributes('href')).toBe('blob_path.txt');
      expect(file().text()).toBe('test.txt');
    });

    it('shows the correct line number when there is a start line', () => {
      createWrapper({ location: { file: 'test.txt', start_line: 24, blob_path: 'blob.txt' } });
      expect(file().attributes('target')).toBe('_blank');
      expect(file().attributes('href')).toBe('blob.txt#L24');
      expect(file().text()).toBe('test.txt:24');
    });

    it('shows the correct line numbers when there is a start and end line', () => {
      createWrapper({
        location: { file: 'test.txt', start_line: 24, end_line: 27, blob_path: 'blob.txt' },
      });
      expect(file().attributes('target')).toBe('_blank');
      expect(file().attributes('href')).toBe('blob.txt#L24-27');
      expect(file().text()).toBe('test.txt:24-27');
    });

    it('shows only the start line when the end line is the same', () => {
      createWrapper({
        location: { file: 'test.txt', start_line: 24, end_line: 24, blob_path: 'blob.txt' },
      });
      expect(file().attributes('target')).toBe('_blank');
      expect(file().attributes('href')).toBe('blob.txt#L24');
      expect(file().text()).toBe('test.txt:24');
    });
  });

  describe('scanner', () => {
    const link = () => getById('scannerSafeLink');
    const scannerText = () => getById('scanner').text();

    it('shows the scanner name only but no link', () => {
      createWrapper({ scanner: { name: 'some scanner' } });
      expect(scannerText()).toBe('Scanner: some scanner');
      expect(link().element instanceof HTMLSpanElement).toBe(true);
    });

    it('shows the scanner name and version but no link', () => {
      createWrapper({ scanner: { name: 'some scanner', version: '1.2.3' } });
      expect(scannerText()).toBe('Scanner: some scanner (version 1.2.3)');
      expect(link().element instanceof HTMLSpanElement).toBe(true);
    });

    it('shows the scanner name only with a link', () => {
      createWrapper({ scanner: { name: 'some scanner', url: '//link' } });
      expect(scannerText()).toBe('Scanner: some scanner');
      expect(link().attributes('href')).toBe('//link');
    });

    it('shows the scanner name and version with a link', () => {
      createWrapper({ scanner: { name: 'some scanner', version: '1.2.3', url: '//link' } });
      expect(scannerText()).toBe('Scanner: some scanner (version 1.2.3)');
      expect(link().attributes('href')).toBe('//link');
    });
  });

  describe('http data', () => {
    const TEST_HEADERS = [{ name: 'Name1', value: 'Value1' }, { name: 'Name2', value: 'Value2' }];
    const TEST_URL = 'http://foo.bar/test';
    const EXPECT_HEADERS = {
      label: 'Headers:',
      content: 'Name1: Value1\nName2: Value2',
      isCode: true,
    };

    const getTextContent = el => el.textContent.trim();
    const getLabel = el => getTextContent(getByTestId(el, 'label'));
    const getContent = el => getTextContent(getByTestId(el, 'value'));
    const getSectionData = testId => {
      const section = getById(testId).element;

      if (!section) {
        return null;
      }

      return getAllByRole(section, 'listitem').map(li => ({
        label: getLabel(li),
        content: getContent(li),
        ...(li.querySelector('code') ? { isCode: true } : {}),
      }));
    };

    it.each`
      request                                                    | expectedData
      ${{}}                                                      | ${null}
      ${{ headers: TEST_HEADERS }}                               | ${[EXPECT_HEADERS]}
      ${{ headers: TEST_HEADERS, method: 'GET' }}                | ${[{ label: 'Method:', content: 'GET' }, EXPECT_HEADERS]}
      ${{ headers: TEST_HEADERS, method: 'GET', url: TEST_URL }} | ${[{ label: 'Method:', content: 'GET' }, { label: 'URL:', content: TEST_URL }, EXPECT_HEADERS]}
      ${{ url: TEST_URL }}                                       | ${[{ label: 'URL:', content: TEST_URL }]}
      ${{ method: 'GET' }}                                       | ${[{ label: 'Method:', content: 'GET' }]}
    `('shows request data for $request', ({ request, expectedData }) => {
      createWrapper({ request });
      expect(getSectionData('request')).toEqual(expectedData);
    });

    it.each`
      response                                                            | expectedData
      ${{}}                                                               | ${null}
      ${{ headers: TEST_HEADERS }}                                        | ${[EXPECT_HEADERS]}
      ${{ headers: TEST_HEADERS, status_code: 200 }}                      | ${[EXPECT_HEADERS]}
      ${{ headers: TEST_HEADERS, status_code: 200, reason_phrase: 'OK' }} | ${[{ label: 'Status:', content: '200 OK' }, EXPECT_HEADERS]}
      ${{ status_code: 400, reason_phrase: 'Something bad' }}             | ${[{ label: 'Status:', content: '400 Something bad' }]}
    `('shows response data for $response', ({ response, expectedData }) => {
      createWrapper({ response });
      expect(getSectionData('response')).toEqual(expectedData);
    });
  });
});
