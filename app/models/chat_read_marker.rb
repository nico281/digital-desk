class ChatReadMarker < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  belongs_to :booking, optional: true
end
