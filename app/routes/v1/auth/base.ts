'use strict';

import * as express from 'express';
import * as console from 'console';
import * as HttpStatus from 'http-status';
import {response} from '../../../extend';

const router = express.Router();

router.use((req, res, next) => {
    console.log(`${req.method} ${req.url} \n ${req.params}`);
    next();
});

router.post('/', (req, res, next) => {
    if (req.params.username && req.params.password) {
        response(res, HttpStatus.OK, {
            username: req.params.username,
            password: req.params.password
        });
    } else {
        response(res, HttpStatus.UNAUTHORIZED);
    }
});

module.exports = router;
