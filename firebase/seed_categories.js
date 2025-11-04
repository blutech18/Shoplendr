// Seed script for creating initial categories
// Run this in Firebase Console or as a Cloud Function

const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const categories = [
  {
    name: 'Books',
    description: 'Textbooks, novels, study materials, and academic resources',
    icon_url: '',
    display_order: 1,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Electronics',
    description: 'Laptops, phones, tablets, calculators, and gadgets',
    icon_url: '',
    display_order: 2,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Uniforms',
    description: 'School uniforms, PE attire, and dress code items',
    icon_url: '',
    display_order: 3,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Dorm Essentials',
    description: 'Furniture, appliances, bedding, and room decorations',
    icon_url: '',
    display_order: 4,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Sports & Fitness',
    description: 'Sports equipment, gym gear, and athletic wear',
    icon_url: '',
    display_order: 5,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Arts & Crafts',
    description: 'Art supplies, craft materials, and creative tools',
    icon_url: '',
    display_order: 6,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Musical Instruments',
    description: 'Guitars, keyboards, drums, and music accessories',
    icon_url: '',
    display_order: 7,
    is_active: true,
    product_count: 0,
  },
  {
    name: 'Others',
    description: 'Miscellaneous items and general merchandise',
    icon_url: '',
    display_order: 99,
    is_active: true,
    product_count: 0,
  },
];

async function seedCategories() {
  const batch = db.batch();
  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  for (const category of categories) {
    const docRef = db.collection('Categories').doc();
    batch.set(docRef, {
      ...category,
      created_at: timestamp,
      updated_at: timestamp,
    });
  }

  await batch.commit();
  console.log(`✅ Successfully created ${categories.length} categories`);
}

// Run the seed function
seedCategories()
  .then(() => {
    console.log('🎉 Seeding complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error seeding categories:', error);
    process.exit(1);
  });
