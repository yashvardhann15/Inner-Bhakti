const mongoose = require('mongoose');
const Program = require('./models/program');

mongoose.connect('mongodb://localhost:27017/inner_bhakti', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const initialData = [
  {
    title: 'Peace of Mind',
    description: 'A program that helps you find peace of mind in a busy world. Listen to the soothing voice of our host as she guides you through meditation and relaxation techniques.',
    imageUrl: 'assets/images/program1/program1.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program1/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program1/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program1/episode3.mp3' },
      { title: 'Chapter 4', duration: '25:00', audioUrl: 'program1/episode4.mp3' },
    ],
  },

  {
    title: 'Mindfulness',
    description: 'Learn how to be mindful in your daily life with this program. Our host will teach you how to be present in the moment and appreciate the little things in life.',
    imageUrl: 'assets/images/program2/program2.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program2/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program2/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program2/episode3.mp3' },
    ],
  },

  {
    title: 'Stress Relief',
    description: 'Feeling stressed out? This program is for you. Our host will help you relax and unwind with guided meditation and breathing exercises.',
    imageUrl: 'assets/images/program3/program3.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program3/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program3/episode2.mp3' },
    ],
  },

  {
    title: 'Yoga for Beginners',
    description: 'Start your yoga journey with this program. Our host will teach you the basics of yoga and help you get started on your practice.',
    imageUrl: 'assets/images/program4/program4.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program4/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program4/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program4/episode3.mp3' },
      { title: 'Chapter 4', duration: '25:00', audioUrl: 'program4/episode4.mp3' },
      { title: 'Chapter 5', duration: '25:00', audioUrl: 'program4/episode5.mp3' },
    ],
  },

  {
    title: 'Healthy Eating',
    description: 'Learn how to eat healthy with this program. Our host will share tips and recipes for nutritious meals that are good for your body and mind.',
    imageUrl: 'assets/images/program5/program5.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program5/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program5/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program5/episode3.mp3' },
    ],
  },

  {
    title: 'Positive Thinking',
    description: 'Change your mindset with this program. Our host will help you cultivate a positive attitude and see the bright side of life.',
    imageUrl: 'assets/images/program6/program6.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program6/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program6/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program6/episode3.mp3' },
    ],
  },

  {
    title: 'Self-Care',
    description: 'Take care of yourself with this program. Our host will teach you how to prioritize your well-being and make time for self-care.',
    imageUrl: 'assets/images/program7/program7.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program7/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program7/episode2.mp3' },
    ]
  },

  {
    title: 'Relaxation',
    description: 'Relax and unwind with this program. Our host will help you de-stress and find peace in your busy life.',
    imageUrl: 'assets/images/program8/program8.jpg',
    episodes: [
      { title: 'Chapter 1', duration: '30:00', audioUrl: 'program8/episode1.mp3' },
      { title: 'Chapter 2', duration: '25:00', audioUrl: 'program8/episode2.mp3' },
      { title: 'Chapter 3', duration: '25:00', audioUrl: 'program8/episode3.mp3' },
    ],
  }
];

async function populateDatabase() {
  try {
    await Program.deleteMany({}); // Clear existing data
    await Program.insertMany(initialData);
    console.log('Database populated successfully');
  } catch (error) {
    console.error('Error populating database:', error);
  } finally {
    mongoose.disconnect();
  }
}

populateDatabase();