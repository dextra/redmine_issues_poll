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

class AddBetVotesToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :bet_votes, :integer, :default => 0
    Issue.update_all(:bet_votes => 0)
  end

  def self.down
    remove_column :issues, :bet_votes
  end
end
