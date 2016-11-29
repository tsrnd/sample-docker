'use strict'

const express = require('express')
const router = express.Router()

/* GET home page. */
router.get('/', function (req, res) {
  res.render('index', { title: 'Express' })
})

router.post('', function (req, res) {
  res.json(req.headers)
})

module.exports = router
