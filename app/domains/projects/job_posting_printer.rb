# frozen_string_literal: true

module Projects
  class JobPostingPrinter
    attr_reader :job_posting

    def initialize(project)
      @job_posting = JobPostingDecorator.decorate(project)
    end

    def render
      JobPostingBlueprint.render(job_posting)
    end
  end
end
