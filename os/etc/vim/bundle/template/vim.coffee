module.exports = =>


if not module.parent then do =>
  await module.exports()
  process.exit()

# module.exports = {

# }
