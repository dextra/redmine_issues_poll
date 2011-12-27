class PollsController < ApplicationController
  unloadable
  
  before_filter :find_project, :authorize
  before_filter :get_statuses, :only => [:index, :set_statuses]
  
  verify :method => [:post], :only => [:set_hours, :set_statuses], :render => { :nothing => true, :status => :method_not_allowed }
  
  def get_statuses
    @statuses = IssueStatus.find(:all, :order => 'position')
    @eligible_statuses = EligibleStatus.find(:all).collect{ |status| status.status_id }
  end
  
  def index
    @users = @project.users.collect {|user| {'login' => user.login, 'fullname' => user.firstname + " " + user.lastname, 'hours' => user.polls_hours_project(@project.id)}}
    @login = {'order' => 'asc', 'class' => ''}
    @name = {'order' => 'asc', 'class' => ''}
    @hours = {'order' => 'asc', 'class' => ''}
    
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
    elsif params[:order_hours]
      if params[:order_hours] == "asc"
        @hours = {'order' => 'desc', 'class' => 'sort asc'}
        @users = @users.sort{|a, b| a['hours'] <=> b['hours'] }
      else
        @hours = {'order' => 'asc', 'class' => 'sort desc'}
        @users = @users.sort{|a, b| b['hours'] <=> a['hours'] }
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
  
  def set_hours
    hours = params[:hours]
    if /^\d+$/.match(hours)
      @project.users.each do |user|
        current_poll_hours = user.poll_hours.find(:first, :conditions => ["project_id = ?", @project.id])
        if current_poll_hours
          current_poll_hours.update_attribute(:hours, params[:hours])
        else
          user.poll_hours << @project.poll_hours.new(:hours => hours)
        end
      end
      flash[:notice] = t(:assignment_successful)
    else
      flash[:error] = l(:invalid_hours)
    end
    redirect_to :action => 'index', :tab => 'config'
  end
  
  def bet
    @issue = Issue.find(:first, :conditions => ["id = ? AND project_id = ?", params[:issue_id], @project.id])
    user = User.current
    render :update do |page|
      if @issue and user.can_bet?(@issue.project_id) and @issue.can_receive_bet?
        @bet = Bet.find(:first, :conditions => ["user_id=? AND issue_id=?", user.id, @issue.id])
        @new_bet = Bet.new(params[:bet])
        if @bet
          @bet.hours += @new_bet.hours
        else
          @bet = @new_bet
          @bet.issue_id = @issue.id
          @bet.user_id = user.id
        end
        
        if @bet.save
          poll_hour = user.poll_hours.find(:first, :conditions => ["project_id = ?", @issue.project_id])
          poll_hour.hours -= @new_bet.hours
          poll_hour.save
          @issue.bet_hours ||= 0
          @issue.bet_hours += @new_bet.hours
          @issue.save
          page.alert(t(:bet_successful_created))
        end
      end
      page.replace_html :issues_polls_area, :partial => 'hooks/view_polls_form'
    end
  end
  
  def cancel_bet
    @issue = Issue.find(:first, :conditions => ["id = ? AND project_id = ?", params[:issue_id], @project.id])
    user = User.current
    
    render :update do |page|
      if @issue and user.can_bet?(@issue.project_id) and @issue.can_receive_bet?
        bet = Bet.find(:first, :conditions => ["user_id=? AND issue_id=?", user.id, @issue.id])
        
        if bet
          poll_hour = user.poll_hours.find(:first, :conditions => ["project_id = ?", @issue.project_id])
          poll_hour.hours += bet.hours
          poll_hour.save
          @issue.bet_hours ||= 0
          @issue.bet_hours -= bet.hours
          @issue.save
          bet.destroy
          page.alert(t(:bet_successful_canceled))
        end
      end
      page.replace_html :issues_polls_area, :partial => 'hooks/view_polls_form'
    end
  end
  
  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
