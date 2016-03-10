console.log 'testutils'

noflo = require 'noflo'
unless noflo.isBrowser()
  fs = require 'fs'
  Canvas = require('noflo-canvas').canvas

createCanvas = (width, height) ->
  if noflo.isBrowser()
    canvas = document.createElement 'canvas'
    canvas.width = width
    canvas.height = height
  else
    Canvas = require('noflo-canvas').canvas
    canvas = new Canvas width, height
  return canvas

getImageData = (name, callback) ->
  if noflo.isBrowser()
    id = 'http://localhost:8000/spec/fixtures/'+name
    image = new Image()
    image.onload = ->
      callback image
    image.src = id
  else
    id = 'spec/fixtures/'+name
    fs.readFile id, (err, data) ->
      image = new Canvas.Image
      image.src = data
      callback image
  return id

getCanvasWithImage = (name, callback) ->
  id = getImageData name, (img) ->
    canvas = createCanvas img.width, img.height
    canvas.getContext('2d').drawImage img, img.width*0.25, img.height*0.25
    callback canvas
  return id

getCanvasWithImageNoShift = (name, callback) ->
  id = getImageData name, (img) ->
    canvas = createCanvas img.width, img.height
    canvas.getContext('2d').drawImage img, 0, 0
    callback canvas
  return id

getData = (name, def) ->
  p = './fixtures/' + name
  try
    return require p
  catch err
    console.log 'WARN: getData():', err.message
    return def || {}

getBuffer = (name, callback) ->
  fs.readFile name, (err, data) ->
    if err
      console.log 'ERROR: getBuffer():', err.message
      callback {}
    callback data

writeOut = (path, data) ->
  path = 'spec/fixtures/'+path
  unless noflo.isBrowser()
    fs.writeFileSync path, JSON.stringify data

writePNG = (path, canvas) ->
  path = 'spec/fixtures/'+path
  out = fs.createWriteStream path
  unless noflo.isBrowser()
    stream = canvas.pngStream()
    stream.on 'data', (chunk) ->
      out.write(chunk)
    stream.on 'end', () ->
      console.log 'Saved PNG file in', path

exports.getData = getData
exports.getBuffer = getBuffer
exports.writeOut = writeOut
exports.writePNG = writePNG
exports.getCanvasWithImage = getCanvasWithImage
exports.getCanvasWithImageNoShift = getCanvasWithImageNoShift
