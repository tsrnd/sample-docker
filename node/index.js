const app = require('./app')
const console = require('console')
const port = 3000

app.listen(port, function (error) {
  if (error) {
    throw error
  }
  console.log(`Server is listening on ${port}...`)
})
