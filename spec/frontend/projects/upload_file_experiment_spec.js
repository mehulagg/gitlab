import ExperimentTracking from '~/experimentation/experiment_tracking';
import * as UploadFileExperiment from '~/projects/upload_file_experiment';

const mockExperimentTrackingEvent = jest.fn();
jest.mock('~/experimentation/experiment_tracking', () =>
  jest.fn().mockImplementation(() => ({
    event: mockExperimentTrackingEvent,
  })),
);

const fixture = `<a class='js-upload-file-experiment-trigger' data-toggle='modal' data-target='#modal-upload-blob'></a><div id='modal-upload-blob'></div>`;
const findModal = () => document.querySelector('[aria-modal="true"]');
const findTrigger = () => document.querySelector('.js-upload-file-experiment-trigger');

beforeEach(() => {
  ExperimentTracking.mockClear();
  mockExperimentTrackingEvent.mockClear();

  document.body.innerHTML = fixture;
});

afterEach(() => {
  document.body.innerHTML = '';
});

describe('trackUploadFileFormSubmitted', () => {
  it('initializes ExperimentTracking with the correct arguments and calls the tracking event with correct arguments', () => {
    UploadFileExperiment.trackUploadFileFormSubmitted();

    expect(ExperimentTracking).toHaveBeenCalledWith('empty_repo_upload', {
      label: 'blob-upload-modal',
    });
    expect(mockExperimentTrackingEvent).toHaveBeenCalledWith('click_upload_modal_form_submit');
  });
});

describe('initUploadFileTrigger', () => {
  it('calls modal and tracks event', () => {
    UploadFileExperiment.initUploadFileTrigger();

    expect(findModal()).not.toExist();
    findTrigger().click();
    expect(findModal()).toExist();
    expect(mockExperimentTrackingEvent).toHaveBeenCalledWith('click_upload_modal_trigger');
  });
});
