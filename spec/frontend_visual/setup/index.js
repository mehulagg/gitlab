// import initStoryshots from './node_modules/@storybook/addon-storyshots';
// initStoryshots();

const { toMatchImageSnapshot } = require('jest-image-snapshot');
expect.extend({ toMatchImageSnapshot });

// import initStoryshots, { imageSnapshot } from './node_modules/@storybook/addon-storyshots';
//
// initStoryshots({suite: 'Image storyshots', test: imageSnapshot()});
