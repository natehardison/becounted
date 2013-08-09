require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end
  
  describe "during creation" do

    it "should initialize its status to \"invited\"" do
      @user.should_receive(:set_initial_status)
      @user.save!
    end
  end
  
  describe "right after create" do
    
    it "should not have a voting method" do
      @user.voting_method.should be_nil  
    end
    
    it "should have a status of \"invited\"" do
      @user.status.should == 'invited'
    end
    
    it "should not have any achievements" do
      
    end
  end
  
  describe "#next_end_deadline" do
    
  end
  
  describe "#next_start_deadline" do
    
  end
  
  describe "#revert_to" do
    
  end
  
  describe "#start_over" do
    
  end
  
  describe "#update_score" do
    
  end
  
  describe "#voting_absentee?" do
    it "should " do
      
    end
  end
  
  describe "user's status" do
    
  end
end

describe User, " right after walkthrough" do
  before :each do
    @user = User
  end
  
  it "should have a home state" do
    
  end
  
  it "should have a college" do
    
  end
  
  it "should have a voting method" do
    
  end
  
  it "shouldn't have to do absentee registration if voting in person" do
   # @user.status = 'reg_form_complete'
   # @user.advance_status
   # @user.should have status 'vote_pending'
  end
  
  it "shouldn't have to register if voting in state where already registered" do
    
  end
end

describe User, " while" do
  
end