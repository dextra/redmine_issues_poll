class PollsController < ApplicationController
  unloadable
  
  before_filter :find_project, :authorize
  before_filter :get_statuses, :only => [:index, :set_statuses]
  
  verify :method => [:post], :only => [:set_votes, :set_statuses, :update_votes], :render => { :nothing => true, :status => :method_not_allowed }
  
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
    votes = params[:votes]
    render :update do |page|
      if /^\d+$/.match(votes)
        user = User.find(params[:user_id])
        current_poll_votes = user.poll_votes.find(:first, :conditions => ["project_id = ?", @project.id])
        if current_poll_votes
          current_poll_votes.update_attribute(:votes, params[:votes])
        else
          user.poll_votes << @project.poll_votes.new(:votes => votes)
        end
        page.replace_html "view_votes_#{user.id}", votes
        page.call('toggleForm', user.id)
        page.alert(t(:assignment_successful))
      else
        page.alert(t(:invalid_votes))
      end
    end
  end
  
  def bet
    @issue = Issue.find(:first, :conditions => ["id = ? AND project_id = ?", params[:issue_id], @project.id])
    user = User.current
    render :update do |page|
      @bet = Bet.new(params[:bet])
      @bet.issue_id = @issue.id
      @bet.user_id = user.id
      
      if @bet.save
        poll_vote = user.poll_votes.find(:first, :conditions => ["project_id = ?", @issue.project_id])
        poll_vote.votes -= @bet.votes
        poll_vote.save
        @issue.bet_votes ||= 0
        @issue.bet_votes += @bet.votes
        @issue.save
        page.replace_html :issues_polls_area, :partial => 'hooks/view_polls_form'
        if @bet.votes > 0
          page.alert(t(:bet_successful_created))
        else
          page.alert(t(:bet_successful_canceled))
        end
      else
        page.alert(@bet.errors.full_messages.join('\n'))
      end
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
