'use strict';

const express = require("express");
const console = require("console");
const HttpStatus = require("http-status");
const extend = require("../../../extend");
const router = express.Router();

router.use('/basic', require('./basic'));

module.exports = router;
