const passport = require('passport')
const LocalStrategy = require('passport-local').Strategy
const middleware = require('./middleware')

const user = {
  username: 'test-user',
  password: 'test-password',
  id: 1
}

/**
 * @param {string} username
 * @param {function} callback
 * @returns
 */
function findUser(username, callback) {
  if (username === user.username) {
    return callback(null, user)
  }
  return callback(null)
}

passport.serializeUser(function (user, callback) {
  callback(null, user.username)
})

passport.deserializeUser(function (username, callback) {
  findUser(username, callback)
})

/**
 */
function main() {
  passport.use(new LocalStrategy(
    function (username, password, completion) {
      findUser(username, function (error, user) {
        if (error) {
          return completion(error)
        }
        if (!user) {
          completion(null, false)
        }
        if (password !== user.password) {
          return completion(null, false)
        }
        return completion(null, user)
      })
    }
  ))

  passport.authenticationMiddleware = middleware
}

module.exports = main
