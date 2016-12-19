'use strict';

const express = require("express");
const HttpStatus = require("http-status");
const rep = require("../../../ext").rep;
const router = express.Router();

router.get('/', (req, res) => {
    const offset = 0;
    const total = 0;
    rep(res, HttpStatus.OK, {
        meta: {
            offset: offset,
            total: total
        },
        data: []
    });
});

router.get('/:userId', (req, res) => {
    rep(res, HttpStatus.OK, {
        userId: req.params.userId
    });
});

module.exports = router;
