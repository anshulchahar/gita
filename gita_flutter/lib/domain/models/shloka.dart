/// Domain model representing a Shloka (verse) from the Bhagavad Gita
class Shloka {
  final int chapter;
  final int verse;
  final String sanskrit;
  final String transliteration;
  final String translation;
  final String? wordMeanings;

  const Shloka({
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.transliteration,
    required this.translation,
    this.wordMeanings,
  });

  String get id => '$chapter.$verse';
}

/// Repository of Bhagavad Gita Shlokas
class ShlokaRepository {
  static Shloka? getShloka(int chapter, int verse) {
    return _shlokas['$chapter.$verse'];
  }

  static List<Shloka> getShlokas(int chapter, List<int> verses) {
    return verses
        .map((v) => _shlokas['$chapter.$v'])
        .whereType<Shloka>()
        .toList();
  }

  static final Map<String, Shloka> _shlokas = {
    // Chapter 1 - Arjuna Vishada Yoga (The Yoga of Arjuna's Dejection)
    '1.1': const Shloka(
      chapter: 1,
      verse: 1,
      sanskrit: 'धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||१||',
      transliteration: 'dhṛtarāṣṭra uvāca\ndharma-kṣetre kuru-kṣetre samavetā yuyutsavaḥ\nmāmakāḥ pāṇḍavāś caiva kim akurvata sañjaya',
      translation: 'Dhritarashtra said: O Sanjaya, gathered on the holy field of Kurukshetra, eager to fight, what did my sons and the sons of Pandu do?',
    ),
    '1.2': const Shloka(
      chapter: 1,
      verse: 2,
      sanskrit: 'सञ्जय उवाच |\nदृष्ट्वा तु पाण्डवानीकं व्यूढं दुर्योधनस्तदा |\nआचार्यमुपसङ्गम्य राजा वचनमब्रवीत् ||२||',
      transliteration: 'sañjaya uvāca\ndṛṣṭvā tu pāṇḍavānīkaṁ vyūḍhaṁ duryodhanas tadā\nācāryam upasaṅgamya rājā vacanam abravīt',
      translation: 'Sanjaya said: At that time, seeing the army of the Pandavas arrayed in military formation, King Duryodhana approached his teacher Drona and spoke these words.',
    ),
    '1.3': const Shloka(
      chapter: 1,
      verse: 3,
      sanskrit: 'पश्यैतां पाण्डुपुत्राणामाचार्य महतीं चमूम् |\nव्यूढां द्रुपदपुत्रेण तव शिष्येण धीमता ||३||',
      transliteration: 'paśyaitāṁ pāṇḍu-putrāṇām ācārya mahatīṁ camūm\nvyūḍhāṁ drupada-putreṇa tava śiṣyeṇa dhīmatā',
      translation: 'Behold, O teacher, this mighty army of the sons of Pandu, arrayed by the son of Drupada, your wise disciple.',
    ),
    '1.4': const Shloka(
      chapter: 1,
      verse: 4,
      sanskrit: 'अत्र शूरा महेष्वासा भीमार्जुनसमा युधि |\nयुयुधानो विराटश्च द्रुपदश्च महारथः ||४||',
      transliteration: 'atra śūrā maheṣv-āsā bhīmārjuna-samā yudhi\nyuyudhāno virāṭaś ca drupadaś ca mahā-rathaḥ',
      translation: 'Here are heroes, mighty archers, equal in battle to Bhima and Arjuna: Yuyudhana, Virata, and Drupada, the great warrior.',
    ),
    '1.5': const Shloka(
      chapter: 1,
      verse: 5,
      sanskrit: 'धृष्टकेतुश्चेकितानः काशिराजश्च वीर्यवान् |\nपुरुजित्कुन्तिभोजश्च शैब्यश्च नरपुङ्गवः ||५||',
      transliteration: 'dhṛṣṭaketuś cekitānaḥ kāśirājaś ca vīryavān\npurujit kuntibhojaś ca śaibyaś ca nara-puṅgavaḥ',
      translation: 'Dhrishtaketu, Chekitana, the valiant king of Kashi, Purujit, Kuntibhoja, and Shaibya, the best of men.',
    ),
    '1.6': const Shloka(
      chapter: 1,
      verse: 6,
      sanskrit: 'युधामन्युश्च विक्रान्त उत्तमौजाश्च वीर्यवान् |\nसौभद्रो द्रौपदेयाश्च सर्व एव महारथाः ||६||',
      transliteration: 'yudhāmanyuś ca vikrānta uttamaujāś ca vīryavān\nsaubhadro draupadeyāś ca sarva eva mahā-rathāḥ',
      translation: 'The courageous Yudhamanyu, the valiant Uttamauja, the son of Subhadra, and the sons of Draupadi—all of them great chariot warriors.',
    ),
    '1.7': const Shloka(
      chapter: 1,
      verse: 7,
      sanskrit: 'अस्माकं तु विशिष्टा ये तान्निबोध द्विजोत्तम |\nनायका मम सैन्यस्य संज्ञार्थं तान्ब्रवीमि ते ||७||',
      transliteration: 'asmākaṁ tu viśiṣṭā ye tān nibodha dvijottama\nnāyakā mama sainyasya saṁjñārthaṁ tān bravīmi te',
      translation: 'But know also, O best of the twice-born, the distinguished warriors on our side, the leaders of my army. I name them for your information.',
    ),
    '1.8': const Shloka(
      chapter: 1,
      verse: 8,
      sanskrit: 'भवान्भीष्मश्च कर्णश्च कृपश्च समितिञ्जयः |\nअश्वत्थामा विकर्णश्च सौमदत्तिस्तथैव च ||८||',
      transliteration: 'bhavān bhīṣmaś ca karṇaś ca kṛpaś ca samitiṁjayaḥ\naśvatthāmā vikarṇaś ca saumadattis tathaiva ca',
      translation: 'Yourself, Bhishma, Karna, and Kripa who is ever victorious in battle; Ashvatthama, Vikarna, and the son of Somadatta.',
    ),
    '1.9': const Shloka(
      chapter: 1,
      verse: 9,
      sanskrit: 'अन्ये च बहवः शूरा मदर्थे त्यक्तजीविताः |\nनानाशस्त्रप्रहरणाः सर्वे युद्धविशारदाः ||९||',
      transliteration: 'anye ca bahavaḥ śūrā mad-arthe tyakta-jīvitāḥ\nnānā-śastra-praharaṇāḥ sarve yuddha-viśāradāḥ',
      translation: 'And many other heroes who are prepared to lay down their lives for my sake, armed with various weapons, all skilled in warfare.',
    ),
    
    // Chapter 2 - Sankhya Yoga (The Yoga of Knowledge)
    '2.1': const Shloka(
      chapter: 2,
      verse: 1,
      sanskrit: 'सञ्जय उवाच |\nतं तथा कृपयाविष्टमश्रुपूर्णाकुलेक्षणम् |\nविषीदन्तमिदं वाक्यमुवाच मधुसूदनः ||१||',
      transliteration: 'sañjaya uvāca\ntaṁ tathā kṛpayāviṣṭam aśru-pūrṇākulekṣaṇam\nviṣīdantam idaṁ vākyam uvāca madhusūdanaḥ',
      translation: 'Sanjaya said: To him who was thus overcome with pity, whose eyes were filled with tears and agitated, who was despondent, Madhusudana (Krishna) spoke these words.',
    ),
    '2.2': const Shloka(
      chapter: 2,
      verse: 2,
      sanskrit: 'श्रीभगवानुवाच |\nकुतस्त्वा कश्मलमिदं विषमे समुपस्थितम् |\nअनार्यजुष्टमस्वर्ग्यमकीर्तिकरमर्जुन ||२||',
      transliteration: 'śrī-bhagavān uvāca\nkutas tvā kaśmalam idaṁ viṣame samupasthitam\nanārya-juṣṭam asvargyam akīrti-karam arjuna',
      translation: 'The Supreme Lord said: Whence has this dejection come upon you at this perilous hour? It is not befitting an honorable person; it is disgraceful and does not lead to heaven, O Arjuna.',
    ),
    '2.3': const Shloka(
      chapter: 2,
      verse: 3,
      sanskrit: 'क्लैब्यं मा स्म गमः पार्थ नैतत्त्वय्युपपद्यते |\nक्षुद्रं हृदयदौर्बल्यं त्यक्त्वोत्तिष्ठ परंतप ||३||',
      transliteration: 'klaibyaṁ mā sma gamaḥ pārtha naitat tvayy upapadyate\nkṣudraṁ hṛdaya-daurbalyaṁ tyaktvottiṣṭha paran-tapa',
      translation: 'Do not yield to unmanliness, O Partha. It does not befit you. Cast off this petty weakness of heart and arise, O scorcher of enemies!',
    ),
    
    // Famous shlokas from Chapter 2
    '2.47': const Shloka(
      chapter: 2,
      verse: 47,
      sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन |\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ||४७||',
      transliteration: 'karmaṇy evādhikāras te mā phaleṣu kadācana\nmā karma-phala-hetur bhūr mā te saṅgo \'stv akarmaṇi',
      translation: 'You have the right to perform your prescribed duty, but you are not entitled to the fruits of action. Never consider yourself the cause of the results of your activities, and never be attached to not doing your duty.',
    ),
    
    // Chapter 3 - Karma Yoga
    '3.1': const Shloka(
      chapter: 3,
      verse: 1,
      sanskrit: 'अर्जुन उवाच |\nज्यायसी चेत्कर्मणस्ते मता बुद्धिर्जनार्दन |\nतत्किं कर्मणि घोरे मां नियोजयसि केशव ||१||',
      transliteration: 'arjuna uvāca\njyāyasī cet karmaṇas te matā buddhir janārdana\ntat kiṁ karmaṇi ghore māṁ niyojayasi keśava',
      translation: 'Arjuna said: O Janardana, O Keshava, if You consider knowledge superior to action, then why do You urge me to engage in this terrible action?',
    ),
    '3.9': const Shloka(
      chapter: 3,
      verse: 9,
      sanskrit: 'यज्ञार्थात्कर्मणोऽन्यत्र लोकोऽयं कर्मबन्धनः |\nतदर्थं कर्म कौन्तेय मुक्तसङ्गः समाचर ||९||',
      transliteration: 'yajñārthāt karmaṇo \'nyatra loko \'yaṁ karma-bandhanaḥ\ntad-arthaṁ karma kaunteya mukta-saṅgaḥ samācara',
      translation: 'Work done as a sacrifice for Vishnu has to be performed, otherwise work causes bondage in this material world. Therefore, O son of Kunti, perform your prescribed duties for His satisfaction, and in that way you will always remain free from bondage.',
    ),
    '3.10': const Shloka(
      chapter: 3,
      verse: 10,
      sanskrit: 'सहयज्ञाः प्रजाः सृष्ट्वा पुरोवाच प्रजापतिः |\nअनेन प्रसविष्यध्वमेष वोऽस्त्विष्टकामधुक् ||१०||',
      transliteration: 'saha-yajñāḥ prajāḥ sṛṣṭvā purovāca prajāpatiḥ\nanena prasaviṣyadhvam eṣa vo \'stv iṣṭa-kāma-dhuk',
      translation: 'In the beginning of creation, the Lord of all creatures sent forth generations of men and demigods, along with sacrifices for Vishnu, and blessed them by saying, "Be thou happy by this sacrifice because its performance will bestow upon you everything desirable for living happily and achieving liberation."',
    ),
    '3.11': const Shloka(
      chapter: 3,
      verse: 11,
      sanskrit: 'देवान्भावयतानेन ते देवा भावयन्तु वः |\nपरस्परं भावयन्तः श्रेयः परमवाप्स्यथ ||११||',
      transliteration: 'devān bhāvayatānena te devā bhāvayantu vaḥ\nparasparaṁ bhāvayantaḥ śreyaḥ param avāpsyatha',
      translation: 'The demigods, being pleased by sacrifices, will also please you, and thus, by cooperation between men and demigods, prosperity will reign for all.',
    ),
  };
}
