const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')
const customConfig = require('./custom')

environment.config.set('resolve.extensions', ['.foo', '.bar'])
environment.config.set('output.filename', '[name].js')

// Merge custom config
environment.config.merge(customConfig)

// Delete a property
environment.config.delete('output.chunkFilename')

environment.loaders.append('vue', vue)
module.exports = environment
