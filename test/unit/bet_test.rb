require File.dirname(__FILE__) + '/../test_helper'

class BetTest < ActiveSupport::TestCase
  fixtures :bets
  
  def test_should_not_save_without_hours
    bet = new_bet
    bet.hours = nil
    assert !bet.save, "bet without hours"
  end
  
  def test_should_not_save_without_user_id
    bet = new_bet
    bet.user_id = nil
    assert !bet.save, "bet without user_id"
  end
  
  
  def test_should_not_save_without_issue_id
    bet = new_bet
    bet.issue_id = nil
    assert !bet.save, "bet without issue_id"
  end
  
  def test_should_not_save_without_enough_hours
    bet = new_bet
    assert !bet.save, "user without enough hours"
  end
  
  def new_bet
    puts "=========================="
    user = create_user
    puts user.id
    project = create_project
    puts project.id
    add_member(user.id, project.id)
    issue = create_issue(project.id)
    puts issue.id
    bet = Bet.new(:hours => 1, :issue_id => issue.id, :user_id => user.id)
  end
  
  def create_user
    u = User.new
    u.login = 'user_test'
    u.firstname = 'user'
    u.lastname = 'test'
    u.mail = 'user_tast@test.com'
    u.save
    u
  end
  
  def create_project
    Project.create(
      :name => "Project test",
      :identifier => "project-test"
    )
  end

  def create_issue(project_id)
    i = Issue.create(:subject => "Issue test", :project_id => project_id, :tracker_id => 2, :author_id => 1 )
    puts "===========================================>>>"
    puts i.errors.full_messages
    i    
  end
  
  def add_member(user_id, project_id)
    m = Member.new
    m.user_id = user_id
    m.project_id = project_id
    m.save
    MemberRole.create(:member_id => m.id, :role_id => 1)
  end
  
end
