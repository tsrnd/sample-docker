const passport = require('passport')

function showWelcome(req, res) {
  res.render('user/welcome')
}

function showProfile(req, res) {
  res.render('user/profile', {
    username: req.user.username
  })
}

function routers(app) {
  app.get('/', showWelcome)
  app.get('/profile', passport.authenticationMiddleware(), showProfile)
  app.post('/login', passport.authenticate('local', {
    successRedirect: '/profile',
    failure: '/'
  }))
}

module.exports = routers
