'use strict'

let express = require('express')
let router = express.Router()
let console = require('console')

router.use(function (req, res, next) {
  console.log(req.method + ' ' + req.url, req.params)
  next()
})

router.get('/', function (req, res, next) {
  let err = new Error()
  err.status = 401
  next(err)
})

router.post('/', function (req, res, next) {
  let err = new Error()
  err.status = 400
  next(err)
})

module.exports = router
