'use strict';

import * as express from 'express';
import * as HttpStatus from 'http-status';
import {response} from '../../extend';
const router = express.Router();

router.get('/', (req, res, next) => {
    response(res, HttpStatus.OK);
});

router.use('/auth', require('./auth'));
router.use('/users', require('./users'));

module.exports = router;
