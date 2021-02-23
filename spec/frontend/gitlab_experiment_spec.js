import GitlabExperiment from '~/gitlab_experiment';

describe('GitlabExperiment', () => {
  const oldGon = window.gon;

  let newGon = {};

  const setup = () => {
    window.gon = newGon;
  };

  afterEach(() => {
    window.gon = oldGon;
  });

  describe('run', () => {
    const controlSpy = jest.fn();
    const candidateSpy = jest.fn();
    const getUpStandUpSpy = jest.fn();

    const variants = {
      use: controlSpy,
      try: candidateSpy,
      getUpStandUp: getUpStandUpSpy,
    }

    describe('when there is no experiment data', () => {
      it('calls control variant', () => {
        GitlabExperiment.run('marley', variants);
        expect(controlSpy).toHaveBeenCalled();
      });
    });

    describe('when experiment variant is "control"', () => {
      beforeEach(() => {
        newGon = { global: { experiment: { marley: { variant: 'control' } } } };
        setup();
      });

      it('calls the get-up-stand-up variant', () => {
        GitlabExperiment.run('marley', variants);
        expect(controlSpy).toHaveBeenCalled();
      });
    });

    describe('when experiment variant is "candidate"', () => {
      beforeEach(() => {
        newGon = { global: { experiment: { marley: { variant: 'candidate' } } } };
        setup();
      });

      it('calls the get-up-stand-up variant', () => {
        GitlabExperiment.run('marley', variants);
        expect(candidateSpy).toHaveBeenCalled();
      });
    });

    describe('when experiment variant is "get-up-stand-up"', () => {
      beforeEach(() => {
        newGon = { global: { experiment: { marley: { variant: 'get_up_stand_up' } } } };
        setup();
      });

      it('calls the get-up-stand-up variant', () => {
        GitlabExperiment.run('marley', variants);
        expect(getUpStandUpSpy).toHaveBeenCalled();
      });
    });
  });
});
