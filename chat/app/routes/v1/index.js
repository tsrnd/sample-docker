'use strict';
const express = require("express");
const HttpStatus = require("http-status");
const rep = require("../../ext").rep;
const router = express.Router();

router.get('/', (req, res, next) => {
    rep(res, HttpStatus.OK);
});

router.use('/auth', require('./auth'));
router.use('/users', require('./users'));

module.exports = router;
