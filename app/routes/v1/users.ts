'use strict';

import * as express from 'express';
import * as HttpStatus from 'http-status';
import {response} from '../../extend';
const router = express.Router();

router.get('/', (req, res) => {
    const offset = 0;
    const total = 0;
    response(res, HttpStatus.OK, {
        meta: {
            offset: offset,
            total: total
        },
        data: []
    });
});

router.get('/:userId', (req, res) => {
    response(res, HttpStatus.OK, {
        userId: req.params.userId
    });
});

module.exports = router;
