'use strict';
const express = require("express");
const HttpStatus = require("http-status");
const extend = require("../../extend");
const router = express.Router();

router.get('/', (req, res, next) => {
    extend.response(res, HttpStatus.OK);
});

router.use('/auth', require('./auth'));
router.use('/users', require('./users'));

module.exports = router;
