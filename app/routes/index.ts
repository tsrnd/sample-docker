"use strict"

import * as express from "express";
const router = express.Router()

/* GET home page. */
router.get("/", (req, res) => {
    res.render("index", {title: "Express"})
})

router.post("", (req, res) => {
    res.json(req.headers)
})

module.exports = router
