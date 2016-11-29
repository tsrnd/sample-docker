'use strict'

const express = require('express')
const router = express.Router()
const console = require('console')
var app = express()

app.post('/', function (req, res) {
  // TODO:
})

router.use(function (req, res, next) {
  console.log(req.method + ' ' + req.url, req.params)
  next()
})

router.get('/', function (req, res, next) {
  const err = new Error()
  err.status = 401
  next(err)
})

router.get()

router.post('/', function (req, res, next) {
  const err = new Error()
  err.status = 400
  next(err)
})

module.exports = router
