const express = require('express')
const exphbs = require('express-handlebars')
const bodyParser = require('body-parser')
const urlParser = bodyParser.urlencoded({ extended: false })
const passport = require('passport')
const session = require('express-session')
const Redis = require('connect-redis')(session)

const path = require('path')
const config = require('../config')

const app = express()
app.use(urlParser)

require('./auth').init(app)

const store = new Redis({ url: config.redis.store.url })

app.use(session({
  store: store,
  secret: config.redis.store.secret,
  resave: false,
  saveUninitialized: false,
}))

app.use(passport.initialize())
app.use(passport.session())

app.engine('.hbs', exphbs({
  defaultLayout: 'layout',
  extname: '.hbs',
  layoutsDir: path.join(__dirname),
  partialsDir: path.join(__dirname),
}))

app.set('view engine', '.hbs')
app.set('views', path.join(__dirname))

require('./user').init(app)
require('./note').init(app)

module.exports = app
