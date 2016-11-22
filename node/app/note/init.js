const passport = require('passport')

function init(app) {
  app.get('/note/:id', passport.authenticationMiddleware(), (req, res) => {
    res.render('note/overview', {
      id: req.params.id
    })
  })
}

module.exports = init
