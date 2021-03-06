noflo = require 'noflo'
sharp = require 'sharp'

# @runtime noflo-nodejs
# @name ResizeBuffer

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image buffer to a new dimension'
  c.defaultDimension = 1024

  c.inPorts.add 'buffer',
    datatype: 'object'
    description: 'Image buffer to be resized'
  c.inPorts.add 'width',
    datatype: 'integer'
    description: 'New width'
    required: false
  c.inPorts.add 'height',
    datatype: 'integer'
    description: 'New height'
    required: false
  c.outPorts.add 'buffer',
    datatype: 'object'
  c.outPorts.add 'factor',
    datatype: 'number'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['buffer']
    params: ['width', 'height']
    out: ['buffer', 'factor']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    console.log 'Warning: This component is deprecated, use Resize instead'
    width = c.params.width
    height = c.params.height
    try
      inputBuffer = sharp payload
      inputBuffer.metadata (err, metadata) ->
        if err
          return callback err
        # Default value when nothing is specified
        if not width? and not height?
          # Deal with narrow or wide images
          if metadata.width > metadata.height
            width = c.defaultDimension
          else
            height = c.defaultDimension
        # Try to preserve the same format, if there's EXIF
        format = if metadata.exif? then 'jpeg' else 'png'
        inputBuffer
        .resize width, height
        .withMetadata()
        .withoutEnlargement()
        .toFormat format
        .toBuffer (err, outputBuffer, info) ->
          if err
            return callback err
          if width
            originalWidth = metadata.width
            resizedWidth = info.width
            factor = originalWidth / resizedWidth
          else
            originalHeight = metadata.height
            resizedHeight = info.height
            factor = originalHeight / resizedHeight
          out.buffer.send outputBuffer
          out.factor.send factor
          do callback
    catch err
      return callback err

  c
