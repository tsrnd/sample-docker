'use strict';

const express = require("express");
const HttpStatus = require("http-status");
const extend_1 = require("../../../extend");
const router = express.Router();

router.get('/', (req, res) => {
    const offset = 0;
    const total = 0;
    extend_1.response(res, HttpStatus.OK, {
        meta: {
            offset: offset,
            total: total
        },
        data: []
    });
});

router.get('/:userId', (req, res) => {
    extend_1.response(res, HttpStatus.OK, {
        userId: req.params.userId
    });
});

module.exports = router;
