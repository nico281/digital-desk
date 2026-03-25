class AddProReplyToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :pro_reply, :text
    add_column :reviews, :pro_replied_at, :datetime
  end
end
