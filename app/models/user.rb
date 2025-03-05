# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  private                :boolean          default(FALSE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Follow Requests Associations
  has_many :sent_follow_requests, class_name: "FollowRequest", foreign_key: "sender_id", dependent: :destroy
  has_many :received_follow_requests, class_name: "FollowRequest", foreign_key: "recipient_id", dependent: :destroy

  # Followers and Following (Only accepted follow requests count)
  has_many :followers, -> { where(follow_requests: { status: "accepted" }) }, through: :received_follow_requests, source: :sender
  has_many :following, -> { where(follow_requests: { status: "accepted" }) }, through: :sent_follow_requests, source: :recipient

  # Ensure username uniqueness
  validates :username, presence: true, uniqueness: true

  # Check if user is private
  def private?
    self.private
  end
end
