# Adapted from http://deathofagremmie.com/2011/12/17/who-s-online-with-redis-python-a-slight-return/
class UsersOnlineService
  USERS_ONLINE_KEY = 'users_online'
  TIME_TO_LIVE = 10.minute

  def track_user(user)
    redis.zadd(USERS_ONLINE_KEY, max, user.id)
    purge
  end

  def online_user_ids
    @online_user_ids ||= redis.zrangebyscore(USERS_ONLINE_KEY, min, max).map(&:to_i)
  end

  def online_users
    User.where(id: online_user_ids)
  end

  def online?(user)
    return if user.blank?
    online_user_ids.include?(user.id)
  end

  def purge
    redis.zremrangebyscore(USERS_ONLINE_KEY, 0, min)
  end

  private

  def redis
    Redis.current
  end

  def min
    max - TIME_TO_LIVE
  end

  def max
    Time.now.to_i
  end
end
