class RemoveOwnerFromTopics < ActiveRecord::Migration
  def change
    remove_reference :topics, :owner, polymorphic: true, index: true
    add_reference :topics, :forum, index: true
  end
end
