"use strict";

import * as express from "express";
import * as console from "console";

const router = express.Router();

router.use((req, res, next) => {
    console.log(`${req.method} ${req.url} \n ${req.params}`);
    next();
});

router.get("/", (req, res, next) => {
    const err = new HTTPError(401);
    next(err);
});

router.post("/", (req, res, next) => {
    const err = new HTTPError(400);
    next(err);
});

module.exports = router;
