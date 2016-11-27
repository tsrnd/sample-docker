let express = require('express')
let router = express.Router()

/* GET users listing. */
router.get('/', function (req, res) {
  res.send('respond with a resource')
})

router.get('/:userId', function (req, res) {
  res.json({
    userId: req.params.userId
  })
})

module.exports = router
