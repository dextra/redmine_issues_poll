require File.dirname(__FILE__) + '/../test_helper'

class BetTest < ActiveSupport::TestCase
  fixtures :bets
  
  def setup
    @user = User.generate!
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @eligible_status = EligibleStatus.generate!
    @issue.status_id = @eligible_status.status_id
    @user.poll_votes << @project.poll_votes.new(:votes => 4)
  end
  
  def test_should_not_save_without_votes
    bet = new_bet
    bet.votes = nil
    assert !bet.save, "bet without votes"
  end
  
  def test_should_not_save_without_author
    bet = new_bet
    bet.author = nil
    assert !bet.save, "bet without author"
  end
  
  
  def test_should_not_save_without_issue
    bet = new_bet
    bet.issue = nil
    assert !bet.save, "bet without issue"
  end
  
  def test_should_not_save_without_enough_votes
    bet = new_bet
    bet.votes = 6
    assert !bet.save, "user without enough votes"
  end
  
  def test_should_not_save_with_less_votes
    bet = new_bet
    bet.votes = -16
    assert !bet.save, "user with less votes"
  end
  
  def test_should_not_save_with_zero_votes
    bet = new_bet
    bet.votes = 0
    assert !bet.save, "user with zero votes"
  end
  
  def new_bet
    Bet.new(:votes => 1, :issue => @issue, :author => @user)
  end
  
end
