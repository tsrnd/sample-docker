"use strict";
const express = require("express");
const router = express.Router();
router.get("/", (req, res) => {
    res.send("respond with a resource");
});
router.get("/:userId", (req, res) => {
    res.json({
        userId: req.params.userId
    });
});
module.exports = router;
//# sourceMappingURL=users.js.map