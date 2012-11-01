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
class PollsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize
  before_filter :get_statuses, :only => [:index, :set_statuses]
  def get_statuses
    @statuses = IssueStatus.find(:all, :order => 'position')
    @eligible_statuses = EligibleStatus.find(:all).collect{ |status| status.status_id }
  end

  def index
    @users = @project.users.collect {|user| {'id' => user.id, 'login' => user.login, 'fullname' => user.name(:firstname_lastname), 'votes' => user.polls_votes_project(@project.id)? user.polls_votes_project(@project.id) : '--'}}
    @login = {'order' => 'asc', 'class' => ''}
    @name = {'order' => 'asc', 'class' => ''}
    @votes = {'order' => 'asc', 'class' => ''}

    if params[:order_login]
      if params[:order_login] == "asc"
        @login = {'order' => 'desc', 'class' => 'sort asc'}
        @users = @users.sort{|a, b| a['login'] <=> b['login'] }
      else
        @login = {'order' => 'asc', 'class' => 'sort desc'}
        @users = @users.sort{|a, b| b['login'] <=> a['login'] }
      end
    elsif params[:order_name]
      if params[:order_name] == "asc"
        @name = {'order' => 'desc', 'class' => 'sort asc'}
        @users = @users.sort{|a, b| a['fullname'] <=> b['fullname'] }
      else
        @name = {'order' => 'asc', 'class' => 'sort desc'}
        @users = @users.sort{|a, b| b['fullname'] <=> a['fullname'] }
      end
    elsif params[:order_votes]
      if params[:order_votes] == "asc"
        @votes = {'order' => 'desc', 'class' => 'sort asc'}
        @users = @users.sort{|a, b| a['votes'] <=> b['votes'] }
      else
        @votes = {'order' => 'asc', 'class' => 'sort desc'}
        @users = @users.sort{|a, b| b['votes'] <=> a['votes'] }
      end
    else
      @login = {'order' => 'desc', 'class' => 'sort asc'}
      @users = @users.sort{|a, b| a['login'] <=> b['login'] }
    end
  end

  def set_statuses
    EligibleStatus.delete_all
    if params[:statuses]
      EligibleStatus.create(params[:statuses].collect{|status| {:status_id => status}})
    end
    flash[:notice] = t(:configuration_successful)
    redirect_to :action => 'index', :tab => 'config'
  end

  def set_votes
    votes = params[:votes]
    if /^\d+$/.match(votes)
      @project.users.each do |user|
        current_poll_votes = user.poll_votes.find(:first, :conditions => ["project_id = ?", @project.id])
        if current_poll_votes
          current_poll_votes.update_attribute(:votes, params[:votes])
        else
          user.poll_votes << @project.poll_votes.new(:votes => votes)
        end
      end
      flash[:notice] = t(:assignment_successful)
    else
      flash[:error] = t(:invalid_votes)
    end
    redirect_to :action => 'index', :tab => 'config'
  end

  def update_votes
    @votes = params[:votes]
    @success = false
    if /^\d+$/.match(@votes)
      @user = User.find(params[:user_id])
      current_poll_votes = @user.poll_votes.find(:first, :conditions => ["project_id = ?", @project.id])
      if current_poll_votes
        current_poll_votes.update_attribute(:votes, params[:votes])
      else
        @user.poll_votes << @project.poll_votes.new(:votes => @votes)
      end
      @success = true
    end
    
    respond_to do |format|
      format.js
    end
    
  end

  def bet
    @issue = Issue.find(:first, :conditions => ["id = ? AND project_id = ?", params[:issue_id], @project.id])
    user = User.current
    @bet = Bet.new(params[:bet])
    @bet.issue_id = @issue.id
    @bet.user_id = user.id
    @added = false
    @success = false
    if @bet.save
      poll_vote = user.poll_votes.find(:first, :conditions => ["project_id = ?", @issue.project_id])
      poll_vote.votes -= @bet.votes
      poll_vote.save
      @issue.bet_votes ||= 0
      @issue.bet_votes += @bet.votes
      @issue.save
      @success = true
      if @bet.votes > 0
        @added = true
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def cancel_bet
    votes = User.current.votes_bet_by_issue(params[:issue_id])
    if votes <= 0
    votes = 0
    else
    votes *= -1
    end
    params[:bet] = {:votes => votes}
    bet
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
    end

end
