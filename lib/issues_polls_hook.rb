# Provides a link to the issue age graph on the issue index page

module IssuesPolls
  
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, :partial => 'hooks/view_polls_info'
  end
  
end