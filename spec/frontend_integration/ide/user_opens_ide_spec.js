import { waitForText } from 'helpers/wait_for_text';
import waitForPromises from 'helpers/wait_for_promises';
import { useOverclockTimers } from 'test_helpers/utils/overclock_timers';
import { findByText, screen } from '@testing-library/dom';
import * as ideHelper from './helpers/ide_helper';

describe('IDE: user opens IDE', () => {
  useOverclockTimers();

  let vm;
  let root;

  beforeEach(() => {
    root = document.createElement('div');
    document.body.appendChild(root);
  });

  afterEach(() => {
    vm.$destroy();
    vm = null;
    root.remove();
  });

  it('shows loading indicator while IDE is loading', async () => {
    vm = ideHelper.createIdeComponent(root);

    expect(root.querySelectorAll('.multi-file-loading-container')).toBeDefined();
  });

  describe('when project is empty', () => {
    beforeEach(() => {
      vm = ideHelper.createIdeComponent(root, { isRepoEmpty: true });
    });

    it('shows No files in left sidebar', async () => {
      expect(await screen.findByText('No files')).toBeDefined();
    });

    it('shows a New file button', async () => {
      const button = await screen.findByTitle('New file');

      expect(button.tagName).toEqual('BUTTON');
    });
  });

  describe('when file tree is loaded', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root);

      await waitForText('README'); // wait for file tree to load
    });

    it('shows file list in the left sidebar', async () => {
      expect(ideHelper.getFilesList()).toEqual(
        expect.arrayContaining(['README', 'LICENSE', 'CONTRIBUTING.md']),
      );
    });

    it('shows empty state in the main editor window', async () => {
      expect(
        await screen.findByText(
          "Select a file from the left sidebar to begin editing. Afterwards, you'll be able to commit your changes.",
        ),
      ).toBeDefined();
    });

    it('shows commit button in disabled state', async () => {
      const button = await screen.findByTestId('begin-commit-button');

      expect(button.getAttribute('disabled')).toBeDefined();
    });

    it('shows branch/MR dropdown with master selected', async () => {
      const dropdown = await screen.findByTestId('ide-nav-dropdown');

      expect(dropdown.textContent).toContain('master');
    });
  });

  describe('a path to a text file is present in the URL', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root, { path: 'README.md' });

      // a new tab is open for README.md
      await findByText(document.querySelector('.multi-file-edit-pane'), 'README.md');
    });

    it('opens the file', async () => {
      expect(await ideHelper.findAndGetEditorValue()).toContain(
        'Sample repo for testing gitlab features',
      );
    });
  });

  describe('a path to a binary file is present in the URL', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root, { path: 'Gemfile.zip' });

      // a new tab is open for Gemfile.zip
      await findByText(document.querySelector('.multi-file-edit-pane'), 'Gemfile.zip');
    });

    it('shows download viewer', async () => {
      const downloadButton = await screen.findByText('Download');

      expect(downloadButton.getAttribute('download')).toEqual('Gemfile.zip');
      expect(downloadButton.getAttribute('href')).toContain('/raw/');
    });
  });

  describe('a path to an image is present in the URL', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root, { path: 'files/images/logo-white.png' });

      // a new tab is open for logo-white.png
      await findByText(document.querySelector('.multi-file-edit-pane'), 'logo-white.png');
    });

    it('shows image viewer', async () => {
      const viewer = await screen.findByTestId('image-viewer');
      const img = viewer.querySelector('img');

      await waitForPromises();
      expect(img.src).toContain('.png');
    });
  });

  describe('path in URL is a directory', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root, { path: 'files/images' });

      // folders in left sidebar are expanded
      await screen.findByText('logo-white.png');
    });

    it('expands folders in the left sidebar', () => {
      expect(ideHelper.getFilesList()).toEqual(
        expect.arrayContaining(['files', 'images', 'logo-white.png', 'logo-black.png']),
      );
    });

    it('shows empty state in the main editor window', async () => {
      expect(
        await screen.findByText(
          "Select a file from the left sidebar to begin editing. Afterwards, you'll be able to commit your changes.",
        ),
      ).toBeDefined();
    });
  });

  describe('path in url doesn\'t exist', () => {
    beforeEach(async () => {
      vm = ideHelper.createIdeComponent(root, { path: 'abracadabra/hocus-focus.txt' });

      // a new tab is open for hocus-focus.txt
      await findByText(document.querySelector('.multi-file-edit-pane'), 'hocus-focus.txt');
    });

    it('create new folders and file in the left sidebar', () => {
      expect(ideHelper.getFilesList()).toEqual(
        expect.arrayContaining(['abracadabra', 'hocus-focus.txt']),
      );
    });

    it('creates a blank new file', async () => {
      expect(await ideHelper.findAndGetEditorValue()).toEqual('\n');
    });
  })
});
