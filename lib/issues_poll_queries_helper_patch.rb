#  Copyright 2011/2012 Dextra Sistemas
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

require_dependency 'queries_helper'

module IssuesPollQueriesHelperPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :retrieve_query, :aditional_column
    end

  end

  module ClassMethods
  end

  module InstanceMethods
    def retrieve_query_with_aditional_column
      if !params[:query_id].blank?
        cond = "project_id IS NULL"
        cond << " OR project_id = #{@project.id}" if @project
        @query = Query.find(params[:query_id], :conditions => cond)
        raise ::Unauthorized unless @query.visible?
        @query.project = @project
        session[:query] = {:id => @query.id, :project_id => @query.project_id}
        sort_clear
      else
        if api_request? || params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
          # Give it a name, required to be valid
          @query = Query.new(:name => "_")
          @query.project = @project
          if params[:fields] || params[:f]
            @query.filters = {}
            @query.add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
          else
            @query.available_filters.keys.each do |field|
              @query.add_short_filter(field, params[field]) if params[field]
            end
          end
          @query.group_by = params[:group_by]
          @query.column_names = params[:c] || (params[:query] && params[:query][:column_names])
          session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
        else
          @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
          @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
          @query.project = @project
        end
      end
      #### Only this was added ####
      if @project and @project.enabled_module_names.include?('issues_poll')
        unless Query.available_columns.collect{|c|c.name}.include?(:bet_votes)
          Query.available_columns << QueryColumn.new(:bet_votes, :sortable => "#{Issue.table_name}.bet_votes", :default_order => 'desc')
          Setting.issue_list_default_columns << "bet_votes"
        end
      else
        Query.available_columns.delete_if{|c| c.name == :bet_votes}
        Setting.issue_list_default_columns.delete( "bet_votes" )
      end
      ##############################
    end
  end

end

QueriesHelper.send(:include, IssuesPollQueriesHelperPatch) unless QueriesHelper.included_modules.include? IssuesPollQueriesHelperPatch
