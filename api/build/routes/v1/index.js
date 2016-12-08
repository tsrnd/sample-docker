'use strict';
const express = require("express");
const HttpStatus = require("http-status");
const router = express.Router();
router.get('/', (req, res) => {
    res.status(HttpStatus.OK).render('index', { title: 'API V1' });
});
router.use('/auth', require('./auth'));
router.use('/users', require('./users'));
module.exports = router;
//# sourceMappingURL=index.js.map