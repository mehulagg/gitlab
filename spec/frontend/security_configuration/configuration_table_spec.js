import { mount } from '@vue/test-utils';
import ConfigurationTable from '~/security_configuration/components/configuration_table.vue';

let wrapper;

const createComponent = () => {
  wrapper = mount(ConfigurationTable, {});
};

const findbyID = (id) => wrapper.find(`[data-test-id="${id}"]`);
const findAllByID = (id) => wrapper.findAll(`[data-test-id="${id}"]`);

afterEach(() => {
  wrapper.destroy();
});

describe('Configuration Table Component', () => {
  it('should render the correct text in SAST name', () => {
    createComponent();
    expect(
      findbyID('sast').element.querySelectorAll('div')[0].innerText.replace(/\s\s+/g, ' ').trim(),
    ).toContain('Static Application Security Testing (SAST)');
  });

  it('should render the correct text in SAST Description', () => {
    createComponent();
    expect(
      findbyID('sast').element.querySelectorAll('div')[1].innerText.replace(/\s\s+/g, ' ').trim(),
    ).toEqual('Analyze your source code for known vulnerabilities. More information');
  });

  it('should render "configure via Merge Request Button" in SAST row', () => {
    createComponent();
    expect(
      findbyID('sast').element.querySelectorAll('div')[1].innerText.replace(/\s\s+/g, ' ').trim(),
    ).toEqual('Analyze your source code for known vulnerabilities. More information');
  });

  it('should render the correct text in DAST name', () => {
    createComponent();
    expect(
      findbyID('dast').element.querySelectorAll('div')[0].innerText.replace(/\s\s+/g, ' ').trim(),
    ).toEqual('Dynamic Application Security Testing (DAST)');
  });

  it('should render the correct text in DAST Description', () => {
    createComponent();
    expect(
      findbyID('dast').element.querySelectorAll('div')[1].innerText.replace(/\s\s+/g, ' ').trim(),
    ).toEqual('Analyze a review version of your web application. More information');
  });

  it('should render the correct text in Secret Detection name', () => {
    createComponent();
    expect(
      findbyID('secret-detection')
        .element.querySelectorAll('div')[0]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Secret Detection');
  });

  it('should render the correct text in Secret Detection Description', () => {
    createComponent();
    expect(
      findbyID('secret-detection')
        .element.querySelectorAll('div')[1]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Analyze your source code and git history for secrets. More information');
  });

  it('should render the correct text in Dependency Scanning name', () => {
    createComponent();
    expect(
      findbyID('dependency-scanning')
        .element.querySelectorAll('div')[0]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Dependency Scanning');
  });

  it('should render the correct text in Dependency Scanning Description', () => {
    createComponent();
    expect(
      findbyID('dependency-scanning')
        .element.querySelectorAll('div')[1]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Analyze your dependencies for known vulnerabilities. More information');
  });

  it('should render the correct text in Container Scanning name', () => {
    createComponent();
    expect(
      findbyID('container-scanning')
        .element.querySelectorAll('div')[0]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Container Scanning');
  });

  it('should render the correct text in Container Scanning Description', () => {
    createComponent();
    expect(
      findbyID('container-scanning')
        .element.querySelectorAll('div')[1]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Check your Docker images for known vulnerabilities. More information');
  });

  it('should render the correct text in Coverage Fuzzing name', () => {
    createComponent();
    expect(
      findbyID('coverage-fuzzing')
        .element.querySelectorAll('div')[0]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Coverage Fuzzing');
  });

  it('should render the correct text in Coverage Fuzzing Description', () => {
    createComponent();
    expect(
      findbyID('coverage-fuzzing')
        .element.querySelectorAll('div')[1]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('Find bugs in your code with coverage-guided fuzzing. More information');
  });

  it('should render the correct text in License Compliance name', () => {
    createComponent();
    expect(
      findbyID('license-compliance')
        .element.querySelectorAll('div')[0]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual('License Compliance');
  });

  it('should render the correct text in License Compliance Description', () => {
    createComponent();
    expect(
      findbyID('license-compliance')
        .element.querySelectorAll('div')[1]
        .innerText.replace(/\s\s+/g, ' ')
        .trim(),
    ).toEqual(
      'Search your project dependencies for their licenses and apply policies. More information',
    );
  });

  it('should render Configure via Merge Request Button', () => {
    createComponent();
    expect(findbyID('manage-sast').element.innerText.replace(/\s\s+/g, ' ').trim()).toEqual(
      'Configure via Merge Request',
    );
  });

  it('should render "Available with upgrade or free trial" Button 5x', () => {
    createComponent();
    const elems = findAllByID('upgrade');
    expect(elems.length).toEqual(5);

    elems.wrappers.map((elem) => {
      expect(elem.element.innerText.replace(/\s\s+/g, ' ').trim()).toEqual(
        'Available with upgrade or free trial',
      );
    });
  });

  it('should not show error message when there is no error', () => {
    createComponent();
    expect(findbyID('error-message').element).toBe(undefined);
  });

  it('should show error message when onError was called', async function () {
    createComponent();
    wrapper.vm.onError('test error');
    await wrapper.vm.$nextTick();
    expect(findbyID('error-message').element.innerText.replace(/\s\s+/g, ' ').trim()).toEqual(
      'test error',
    );
  });
});
