class ApiConstants {
  // Hava durumu ikon URL'leri
  static const Map<String, String> dayWeatherImages = {
    '01d':
        'https://images.unsplash.com/photo-1598717123623-994ab270a08e', // açık hava
    '02d':
        'https://images.unsplash.com/photo-1601297183305-6df142704ea2', // az bulutlu
    '03d':
        'https://images.unsplash.com/photo-1501630834273-4b5604d2ee31', // parçalı bulutlu
    '04d':
        'https://images.unsplash.com/photo-1525087740718-9e0f2c58c7ef', // çok bulutlu
    '09d':
        'https://images.unsplash.com/photo-1438449805896-28a666819a20', // hafif yağmurlu
    '10d':
        'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17', // yağmurlu
    '11d':
        'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28', // gök gürültülü
    '13d':
        'https://images.unsplash.com/photo-1418985991508-e47386d96a71', // karlı
    '50d':
        'https://images.unsplash.com/photo-1486184885347-1464b5f10296', // sisli
  };

  static const Map<String, String> nightWeatherImages = {
    '01n':
        'https://images.unsplash.com/photo-1507400492013-162706c8c05e', // açık hava gece
    '02n':
        'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b', // az bulutlu gece
    '03n':
        'https://images.unsplash.com/photo-1500740516770-92bd004b996e', // parçalı bulutlu gece
    '04n':
        'https://images.unsplash.com/photo-1500740516770-92bd004b996e', // çok bulutlu gece
    '09n':
        'https://images.unsplash.com/photo-1509114397022-ed747cca3f65', // hafif yağmurlu gece
    '10n':
        'https://images.unsplash.com/photo-1501999635878-71cb5379c2d8', // yağmurlu gece
    '11n':
        'https://images.unsplash.com/photo-1472145246862-b24cf25c4a36', // gök gürültülü gece
    '13n':
        'https://images.unsplash.com/photo-1478265409131-1f65c88f965c', // karlı gece
    '50n':
        'https://images.unsplash.com/photo-1485236715568-ddc5ee6ca227', // sisli gece
  };

  static const Map<String, String> weatherDescriptionImages = {
    'açık': 'https://images.unsplash.com/photo-1598717123623-994ab270a08e',
    'parçalı bulut':
        'https://images.unsplash.com/photo-1501630834273-4b5604d2ee31',
    'bulut': 'https://images.unsplash.com/photo-1525087740718-9e0f2c58c7ef',
    'hafif yağmur':
        'https://images.unsplash.com/photo-1438449805896-28a666819a20',
    'yağmur': 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17',
    'kar': 'https://images.unsplash.com/photo-1418985991508-e47386d96a71',
    'sis': 'https://images.unsplash.com/photo-1486184885347-1464b5f10296',
    'gök gürültü':
        'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28',
  };

  static const String defaultBackgroundUrl =
      'https://images.unsplash.com/photo-1598717123623-994ab270a08e';
}
