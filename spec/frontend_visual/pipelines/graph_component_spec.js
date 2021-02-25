// TODO: Make tests not take so long
// import { toMatchImageSnapshot } from 'jest-image-snapshot';
const { toMatchImageSnapshot } = require('jest-image-snapshot');


const TIMEOUT = 120 * 1000;
jest.setTimeout(TIMEOUT);

describe('Does this even work?', () => {
  it('does', () => {
    expect(true).toBe(true);
  });
});

describe('An attempt', () => {
  let image;

  beforeAll(async () => {
    await page.goto('http://localhost:3000');
    image = await page.screenshot({ fullPage: true });
  });

  it('should be titled "Gitlab"', async () => {
    await expect(page.title()).resolves.toMatch('Sign in · GitLab');
    expect(image).toMatchImageSnapshot();
  });
});

describe('A pipeline attempt', () => {
  let image;

  beforeAll(async () => {
    await page.goto('http://localhost:3000/root/slightly-less-big/-/pipelines/249', {
      waitUntil: 'networkidle0'
    });
    image = await page.screenshot({ fullPage: true });
  });

  it('should display pipeline title', async () => {
    await expect(page.title()).resolves.toMatch('Pipeline · Administrator / slightly less big · GitLab');
    expect(image).toMatchImageSnapshot();
  });
});
