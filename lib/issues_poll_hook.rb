#  Copyright 2011/2013 Dextra Sistemas
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

module IssuesPoll
  
  class Hooks < Redmine::Hook::ViewListener
   
    def view_issues_show_description_bottom(context={})
      context[:controller].send(:render_to_string, {
        :partial => 'hooks/view_polls_info',
        :locals => context
      })
    end
    
    def view_layouts_base_html_head(context={})
      stylesheet_link_tag 'style', :plugin => 'redmine_issues_poll'
    end
  end
  
end