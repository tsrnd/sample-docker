const config = {}

config.redis = {}
config.redis.store = {
  url: process.env.REDIS_STORE_URI,
  secret: process.env.REDIS_STORE_SECRET
}

module.exports = config
