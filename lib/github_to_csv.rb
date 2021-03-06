#!/usr/bin/env ruby

require "rubygems"
require 'yaml'
require 'csv'
require_relative "services/get_issues_from_github"
require_relative "story"

state = ARGV[0] || "open"

# load configuration file

config = YAML.load_file("config.yml")

# reading configurations for github

github_config = config["github"]

github_access_token = github_config["access_token"]

github_project = github_config["projects"]["ancora"]
github_project_repo = github_project["repo"]
github_project_milestone = github_project["milestone"]["backlog"]

# get issues from github

issues = GetIssuesFromGithub.call(
  github_access_token, github_project_repo, github_project_milestone, state
)


# creating csv with issues

CSV.open("github_to_csv.csv", 'wb', col_sep: ",") do |csv|
  csv << ["ID", "Estória", "Comentários", "Prioridade"]
  issues.each do |issue|
    story = Story.create_from_github_issue(issue)
    csv << story.to_csv
  end
end

