# frozen_string_literal: true

module RakeHelpers
  def run_rake_task(task_name, *args, mock_stdout: false)
    Rake::Task[task_name].reenable

    task = "#{task_name}[#{args.join(',')}]"

    if mock_stdout
      expect do
        Rake.application.invoke_task(task)
      end.to output.to_stdout
    else
      Rake.application.invoke_task(task)
    end
  end

  def stub_warn_user_is_not_gitlab
    allow(main_object).to receive(:warn_user_is_not_gitlab)
  end

  def silence_output
    allow(main_object).to receive(:puts)
    allow(main_object).to receive(:print)
  end

  def silence_progress_bar
    allow_any_instance_of(ProgressBar::Output).to receive(:stream).and_return(double.as_null_object)
  end

  def main_object
    @main_object ||= TOPLEVEL_BINDING.eval('self')
  end
end
