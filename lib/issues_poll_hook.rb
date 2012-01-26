# Provides a link to the issue age graph on the issue index page

module IssuesPoll
  
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, :partial => 'hooks/view_polls_info'
    render_on :view_layouts_base_html_head, :partial => "hooks/content_for_header_tags"
  end
  
end