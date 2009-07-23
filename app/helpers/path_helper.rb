module PathHelper
	def user_name_path user
	  return '/' + user.login
	end

	def user_follow_path user
	  return user_name_path(user) + '/follow'
	end
  
  def user_unfollow_path user
    return user_name_path(user) + '/unfollow'
  end
  
	def user_following_path user
	  return user_follow_path(user) + 'ing'
	end

	def user_followers_path user
	  return user_follow_path(user) + 'ers'
	end
end