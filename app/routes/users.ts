"use strict";

import * as express from "express";
const router = express.Router();

/* GET users listing. */
router.get("/", (req, res) => {
    res.send("respond with a resource");
});

router.get("/:userId", (req, res) => {
    res.json({
        userId: req.params.userId
    });
});

module.exports = router;
