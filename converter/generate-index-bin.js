const fs = require('fs');
const _ = require('lodash');
const path = require("path")
const dir = process.argv[2] || "./vid"

// Find and sort files.
const files = _.sortBy(fs.readdirSync(dir).filter(v => /.png$/.test(v)), (v) => {
  return parseFloat(v.replace(/[^0-9]/g, ''))
})

console.log(`${files.length} files found.`);

// Read all the files.
const bins = files.map((file) => {
  console.log(file);
  const buff = fs.readFileSync(path.join(dir, file))
  return buff
})

// Calculate cumulative sum of file sizes
const offsets = _(
  bins.reduce(
    (p, c) => {
      const pos = _.last(p)
      return p.concat(pos + c.length)
    },
    [0]
  )
)
  .drop() // Drop [0]
  .value()

// Peak content
console.log("index.bin", Uint32Array.from(offsets));

// Dump .bin blobs
fs.writeFileSync("index.bin", Buffer.from(Uint32Array.from(offsets).buffer));
fs.writeFileSync("images.bin", Buffer.concat(bins));
