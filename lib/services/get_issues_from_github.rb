require 'octokit'

class GetIssuesFromGithub

  ISSUES_PER_PAGE = 30

  def self.call(access_token, repo_name, milestone_name, state)
    self.new(access_token, repo_name, milestone_name, state).call
  end

  attr_accessor :access_token, :issues, :milestone, :milestone_name,
                :repo_name, :state

  def initialize(access_token, repo_name, milestone_name, state)
    @access_token = access_token
    @repo_name = repo_name
    @milestone_name = milestone_name
    @state = state || 'open'
    @issues = []
  end

  def call
    find_milestone

    return nil if milestone.nil?

    (1..pages(milestone.open_issues)).each do |page|

       _issues = octokit.issues(
                   repo_name,
                   milestone: milestone.number, state: @state, page: page
                 )

       _issues.each do |issue|
         @issues << issue
       end

    end

    issues
  end

  private

  def found_milestone?(milestone)
    milestone.title.include?(milestone_name)
  end

  def find_milestone
    milestones = octokit.list_milestones(repo_name)
    milestones.each do |milestone|
      @milestone = milestone if found_milestone?(milestone)
    end
  end

  def pages(issues_count)
    p = issues_count / ISSUES_PER_PAGE
    p = p + 1 if (issues_count % ISSUES_PER_PAGE) > 0
    p
  end

  def octokit
    Octokit::Client.new(access_token: access_token)
  end

end
