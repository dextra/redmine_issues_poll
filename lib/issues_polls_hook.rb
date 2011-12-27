# Provides a link to the issue age graph on the issue index page

module IssuesPolls
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_show_details_bottom(context={ })
      context[:controller].send(:render_to_string, {
         :partial => 'hooks/view_polls_info',
         :locals => context
      })
    end

  end
end