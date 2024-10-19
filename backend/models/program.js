const mongoose = require('mongoose');

const episodeSchema = new mongoose.Schema({
  title: String,
  duration: String,
  audioUrl: String,
});

const programSchema = new mongoose.Schema({
  title: String,
  description: String,
  imageUrl: String,
  episodes: [episodeSchema],
});

module.exports = mongoose.model('Program', programSchema);