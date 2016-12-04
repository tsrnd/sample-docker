"use strict";
const express = require("express");
const router = express.Router();
router.get("/", (req, res) => {
    res.render("index", { title: "Express" });
});
router.post("", (req, res) => {
    res.json(req.headers);
});
module.exports = router;
//# sourceMappingURL=index.js.map