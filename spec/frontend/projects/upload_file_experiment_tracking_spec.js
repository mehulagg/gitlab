import ExperimentTracking from '~/experiment_tracking';
import { trackFileUploadEvent } from '~/projects/upload_file_experiment_tracking';

const mockExperimentTrackingEvent = jest.fn();
jest.mock('~/experiment_tracking', () =>
  jest.fn().mockImplementation(() => ({
    event: mockExperimentTrackingEvent,
  })),
);

const eventName = 'click_upload_modal_form_submit';
const fixture = `<a class='js-upload-file-experiment-trigger'></a><div class='project-home-panel empty-project'></div>`;

beforeEach(() => {
  ExperimentTracking.mockClear();
  mockExperimentTrackingEvent.mockClear();

  document.body.innerHTML = fixture;
});

afterEach(() => {
  document.body.innerHTML = '';
});

describe('trackFileUploadEvent', () => {
  it('initializes ExperimentTracking with the correct tracking event', () => {
    trackFileUploadEvent(eventName);

    expect(mockExperimentTrackingEvent).toHaveBeenCalledWith(eventName);
  });

  it('calls ExperimentTracking with the correct arguments', () => {
    trackFileUploadEvent(eventName);

    expect(ExperimentTracking).toHaveBeenCalledWith('empty_repo_upload', {
      label: 'blob-upload-modal',
      property: 'empty',
    });
  });

  it('calls ExperimentTracking with the correct arguments when the project is not empty', () => {
    document.querySelector('.empty-project').remove();

    trackFileUploadEvent(eventName);

    expect(ExperimentTracking).toHaveBeenCalledWith('empty_repo_upload', {
      label: 'blob-upload-modal',
      property: 'nonempty',
    });
  });
});
