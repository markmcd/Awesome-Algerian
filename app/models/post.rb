class Post < ActiveRecord::Base
    validates_presence_of :title
    validates_presence_of :image_url
    belongs_to :user
end
