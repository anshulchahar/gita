import json
import os

CONTENT_DIR = "../../content"
UNIT2_PATH = os.path.join(CONTENT_DIR, "unit2.json")

def load_unit2():
    with open(UNIT2_PATH, 'r', encoding='utf-8') as f:
        return json.load(f)

def create_question(id_base, q_type, order, content, xp=25):
    return {
        "questionId": f"{id_base}_{q_type}_{order}",
        "lessonId": id_base,
        "type": q_type,
        "order": order,
        "xpReward": xp,
        "content": content
    }

def main():
    data = load_unit2()
    
    # --- 1. Fix Section 2.1 lessons ---
    # We need to add "The Invincible Self" (Lesson 2.1.4)
    
    # New Lesson Data
    lesson_invincible = {
        "id": "lesson_2_1_4",
        "sectionId": "section_2_1",
        "unitId": "unit_2",
        "lessonNumber": 4, 
        "lessonName": "The Invincible Self",
        "lessonNameHi": "अजेय आत्मा",
        "difficulty": "intermediate",
        "estimatedTime": 300,
        "shlokasCovered": [23, 24, 25],
        "xpReward": 60,
        "prerequisite": None # Will fix later
    }
    
    # Questions for Invincible Self
    q_invincible = [
        create_question("lesson_2_1_4", "scenarioChallenge", 1, {
            "scenarioTitle": "Facing Physical Danger",
            "scenarioTitleHi": "शारीरिक खतरे का सामना",
            "scenario": "You are in a situation where you feel physically threatened or fragile. How does this verse change your mindset?",
            "scenarioHi": "आप ऐसी स्थिति में हैं जहां आप शारीरिक रूप से खतरा या नाजुक महसूस करते हैं। यह श्लोक आपकी मानसिकता को कैसे बदलता है?",
            "options": [
                {"text": "I am weak and breakable.", "textHi": "मैं कमजोर और टूटने योग्य हूं।", "feedback": "That is the body speaking.", "feedbackHi": "यह शरीर बोल रहा है।", "isOptimal": False},
                {"text": "My body can be hurt, but the 'I' within is unbreakable.", "textHi": "मेरे शरीर को चोट लग सकती है, लेकिन भीतर का 'मैं' अटूट है।", "feedback": "Yes. Weapons cannot cut the soul, fire cannot burn it.", "feedbackHi": "हाँ। शस्त्र आत्मा को काट नहीं सकते, आग उसे जला नहीं सकती।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_1_4", "storyCard", 2, {
            "title": "Nainam Chindanti Shastrani",
            "titleHi": "नैनं छिन्दन्ति शस्त्राणि",
            "story": "Krishna declares: 'Weapons cannot cut the soul, fire cannot burn it, water cannot wet it, and wind cannot dry it.' He uses the four elements of nature to show that the Soul is beyond the reach of physical destruction. It is safe, forever.",
            "storyHi": "कृष्ण घोषित करते हैं: 'शस्त्र आत्मा को काट नहीं सकते, आग इसे जला नहीं सकती, पानी इसे भिगो नहीं सकता, और हवा इसे सूखा नहीं सकती।' वे यह दिखाने के लिए प्रकृति के चार तत्वों का उपयोग करते हैं कि आत्मा भौतिक विनाश की पहुंच से परे है। यह सुरक्षित है, हमेशा के लिए।",
            "krishnaMessage": "You are safer than you think."
        }, xp=10),
        create_question("lesson_2_1_4", "multipleChoice", 3, {
            "questionText": "Which element can destroy the soul?",
            "questionTextHi": "कौन सा तत्व आत्मा को नष्ट कर सकता है?",
            "options": ["Fire", "Water", "Wind", "None of them"],
            "optionsHi": ["आग", "पानी", "हवा", "इनमें से कोई नहीं"],
            "correctAnswerIndex": 3,
            "explanation": "The soul is immutable and beyond the reach of physical elements.",
            "explanationHi": "आत्मा अपरिवर्तनीय है और भौतिक तत्वों की पहुंच से परे है।",
            "realLifeApplication": "This gives us immense courage in the face of physical threats or illness."
        }),
         create_question("lesson_2_1_4", "scenarioChallenge", 4, {
            "scenarioTitle": "fear of surgery",
            "scenarioTitleHi": "सर्जरी का डर",
            "scenario": "You need a medical surgery and are terrified. What is the truth?",
            "scenarioHi": "आपको मेडिकल सर्जरी की जरूरत है और आप बहुत डरे हुए हैं। सच क्या है?",
            "options": [
                {"text": "My existence is at risk.", "textHi": "मेरा अस्तित्व खतरे में है।", "feedback": "Only the vehicle is being repaired.", "feedbackHi": "केवल वाहन की मरम्मत की जा रही है।", "isOptimal": False},
                {"text": "The doctors operate on my body, but they cannot touch my Soul.", "textHi": "डॉक्टर मेरे शरीर का ऑपरेशन करते हैं, लेकिन वे मेरी आत्मा को छू नहीं सकते।", "feedback": "Correct. The Soul is witness to the surgery, not the victim.", "feedbackHi": "सही। आत्मा सर्जरी की गवाह है, शिकार नहीं।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_1_4", "reflectionPrompt", 5, {
            "prompt": "Repeat to yourself: 'I am unbreakable.' How does that make you feel?",
            "promptHi": "अपने आप से दोहराएं: 'मैं अटूट हूं।' यह आपको कैसा महसूस कराता है?",
            "krishnaWisdom": "The Soul is eternal, Sarvagatah (all-pervading), Sthanur (stable), and Acalo (immovable)."
        }, xp=20),
    ]

    # --- 2. Fix Section 2.2 lessons ---
    # Merge/Refine "Why Grieve" into "The Warrior's Duty" and add "Focus vs Distraction"
    
    # 2.2.1 Modify "Why Grieve" -> "The Warrior's Duty"
    # We will rename the existing lesson_2_2_1 and update its content
    
    # 2.2.3b New Lesson "Focus vs Distraction"
    lesson_focus = {
        "id": "lesson_2_2_focus", # Temp ID
        "sectionId": "section_2_2",
        "unitId": "unit_2",
        "lessonNumber": 99, 
        "lessonName": "One-Pointed Focus",
        "lessonNameHi": "एकाग्र मन",
        "difficulty": "advanced",
        "estimatedTime": 300,
        "shlokasCovered": [41, 44],
        "xpReward": 70,
        "prerequisite": None
    }
    
    q_focus = [
        create_question("lesson_2_2_focus", "scenarioChallenge", 1, {
            "scenarioTitle": "Too Many Goals",
            "scenarioTitleHi": "बहुत सारे लक्ष्य",
            "scenario": "You want to learn guitar, code, swim, and Spanish all at once. You make no progress. Why?",
            "scenarioHi": "आप एक साथ गिटार, कोडिंग, तैराकी और स्पेनिश सीखना चाहते हैं। आप कोई प्रगति नहीं करते हैं। क्यों?",
            "options": [
                {"text": "I just need to work harder.", "textHi": "मुझे बस और कड़ी मेहनत करनी है।", "feedback": "Effort without focus is waste.", "feedbackHi": "बिना ध्यान के प्रयास बर्बादी है।", "isOptimal": False},
                {"text": "My intelligence is 'many-branched' (bahu-shakha). I need one-pointed focus.", "textHi": "मेरी बुद्धि 'बहु-शाखा' वाली है। मुझे एकाग्रता की आवश्यकता है।", "feedback": "Yes. Vyavasayatmika Buddhi means single-pointed resolve.", "feedbackHi": "हाँ। व्यवसायात्मिका बुद्धि का अर्थ है एकनिष्ठ संकल्प।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_2_focus", "storyCard", 2, {
            "title": "The Many-Branched Intellect",
            "titleHi": "बहु-शाखा वाली बुद्धि",
            "story": "Krishna warns against the 'irresolute mind' which has endless branches. Like a tree spreading in all directions, such a mind chases every new desire, ritual, or fad, never going deep. The resolute mind is like a laser beam—focused on one goal.",
            "storyHi": "कृष्ण 'अस्थिर मन' के खिलाफ चेतावनी देते हैं जिसकी अनंत शाखाएं होती हैं। जैसे एक पेड़ सभी दिशाओं में फैलता है, ऐसा मन हर नई इच्छा, अनुष्ठान या सनक का पीछा करता है, कभी गहरा नहीं जाता। दृढ़ मन एक लेजर बीम की तरह होता है—एक लक्ष्य पर केंद्रित।",
            "krishnaMessage": "Focus is the key to depth."
        }, xp=10),
        create_question("lesson_2_2_focus", "multipleChoice", 3, {
            "questionText": "What is 'Vyavasayatmika Buddhi'?",
            "questionTextHi": "'व्यवसायात्मिका बुद्धि' क्या है?",
            "options": ["Confused mind", "Resolute, one-pointed intellect", "Angry mind", "Sleepy mind"],
            "optionsHi": ["भ्रमित मन", "दृढ़, एकनिष्ठ बुद्धि", "क्रोधित मन", "नींद वाला मन"],
            "correctAnswerIndex": 1,
            "explanation": "It refers to the intellect that has a single, determined aim. Without it, the mind is scattered.",
            "explanationHi": "यह उस बुद्धि को संदर्भित करता है जिसका एक ही, निर्धारित लक्ष्य है। इसके बिना, मन बिखरा हुआ होता है।",
            "realLifeApplication": "Multitasking is often a myth. Success comes from deep work on one thing at a time."
        }),
        create_question("lesson_2_2_focus", "scenarioChallenge", 4, {
            "scenarioTitle": "Chasing Followers",
            "scenarioTitleHi": "फॉलोअर्स का पीछा करना",
            "scenario": "You create art but constantly change your style to get more likes. You feel empty. Why?",
            "scenarioHi": "आप कला बनाते हैं लेकिन अधिक लाइक पाने के लिए अपनी शैली बदलते रहते हैं। आप खाली महसूस करते हैं। क्यों?",
            "options": [
                {"text": "I am chasing external floral words (likes) instead of inner truth.", "textHi": "मैं आंतरिक सत्य के बजाय बाहरी पुष्प शब्दों (लाइक्स) का पीछा कर रहा हूं।", "feedback": "Krishna warns against being misled by 'flowery words' of praise or rituals.", "feedbackHi": "कृष्ण प्रशंसा या अनुष्ठानों के 'पुष्प शब्दों' से गुमराह होने के खिलाफ चेतावनी देते हैं।", "isOptimal": True},
                {"text": "I haven't found the right trend yet.", "textHi": "मुझे अभी तक सही प्रवृत्ति नहीं मिली है।", "feedback": "Trends are endless branches.", "feedbackHi": "प्रवृत्तियाँ अनंत शाखाएँ हैं।", "isOptimal": False}
            ]
        }),
         create_question("lesson_2_2_focus", "reflectionPrompt", 5, {
            "prompt": "What is the ONE thing you truly want to achieve this year? Are you focused on it, or are you chasing 10 other things?",
            "promptHi": "वह एक चीज़ क्या है जिसे आप वास्तव में इस वर्ष प्राप्त करना चाहते हैं? क्या आप उस पर केंद्रित हैं, या आप 10 अन्य चीज़ों का पीछा कर रहे हैं?",
            "krishnaWisdom": "Those who are undecided have infinite, many-branched thoughts."
        }, xp=20),
    ]

    # --- 3. Replace Placeholders ---
    # We will clean up the placeholders in the final list construction
    # But let's define the replacements for existing placeholders
    
    # Placeholder for Free From Anxiety (Lesson 2.2.5 previously, now needs proper questions)
    # The existing unit2.json had a placeholder question for lesson_2_2_5
    
    q_anxiety_replace = [
        create_question("lesson_2_2_5", "scenarioChallenge", 1, {
            "scenarioTitle": "The Result Trap",
            "scenarioTitleHi": "परिणाम जाल",
            "scenario": "You study hard but panic during the exam thinking 'What if I fail?'. This panic makes you forget answers. What happened?",
            "scenarioHi": "आप कड़ी मेहनत से पढ़ाई करते हैं लेकिन परीक्षा के दौरान यह सोचकर घबरा जाते हैं 'अगर मैं फेल हो गया तो क्या होगा?'। यह घबराहट आपको उत्तर भुला देती है। क्या हुआ?",
            "options": [
               {"text": "I didn't study enough.", "textHi": "मैंने पर्याप्त पढ़ाई नहीं की।", "feedback": "No, you did. The anxiety blocked you.", "feedbackHi": "नहीं, आपने की। चिंता ने आपको रोक दिया।", "isOptimal": False},
               {"text": "My attachment to the result (passing) ruined the action (taking the test).", "textHi": "परिणाम (पास होना) के प्रति मेरी आसक्ति ने क्रिया (परीक्षा देना) को बर्बाद कर दिया।", "feedback": "Yes. When we obsess over the fruit, we drop the ball.", "feedbackHi": "हाँ। जब हम फल को लेकर जुनूनी होते हैं, तो हम गेंद छोड़ देते हैं।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_2_5", "storyCard", 2, {
            "title": "Work as Worship",
            "titleHi": "पूजा के रूप में काम",
            "story": "Krishna advises: 'Abandoning all attachment to the results, perform your duties, O Arjuna.' This doesn't mean you don't care. It means you care so much about the WORK that you don't let the fear of the RESULT distract you. It is the secret to total focus.",
            "storyHi": "कृष्ण सलाह देते हैं: 'परिणामों के प्रति सभी आसक्ति को त्यागकर, अपने कर्तव्यों का पालन करो, हे अर्जुन।' इसका मतलब यह नहीं है कि आप परवाह नहीं करते। इसका मतलब है कि आप काम की इतनी परवाह करते हैं कि आप परिणाम के डर को आपको विचलित नहीं करने देते। यह पूर्ण ध्यान का रहस्य है।",
            "krishnaMessage": "Focus on the step, not the summit."
        }, xp=10),
        create_question("lesson_2_2_5", "multipleChoice", 3, {
            "questionText": "What creates anxiety according to Karma Yoga?",
            "questionTextHi": "कर्म योग के अनुसार चिंता क्या पैदा करती है?",
            "options": ["Hard work", "Attachment to outcomes", "Lazy people", "Bad luck"],
            "optionsHi": ["कड़ी मेहनत", "परिणामों के प्रति आसक्ति", "आलसी लोग", "बुरी किस्मत"],
            "correctAnswerIndex": 1,
            "explanation": "Anxiety is simply fear of a future result we cannot control.",
            "explanationHi": "चिंता बस भविष्य के परिणाम का डर है जिसे हम नियंत्रित नहीं कर सकते।",
            "realLifeApplication": "Release the need to control the future, and you release anxiety."
        }),
        create_question("lesson_2_2_5", "scenarioChallenge", 4, {
            "scenarioTitle": "The Sales Call",
            "scenarioTitleHi": "बिक्री कॉल",
            "scenario": "You are making a sales call. If you need the sale desperately to pay rent, do you perform better or worse?",
            "scenarioHi": "आप एक बिक्री कॉल कर रहे हैं। यदि आपको किराया देने के लिए बिक्री की सख्त जरूरत है, तो क्या आप बेहतर या बदतर प्रदर्शन करते हैं?",
            "options": [
               {"text": "Better, because I am motivated.", "textHi": "बेहतर, क्योंकि मैं प्रेरित हूँ।", "feedback": "Desperation often smells like fear.", "feedbackHi": "हताशा अक्सर डर जैसी महकती है।", "isOptimal": False},
               {"text": "Worse, because my desperation makes me pushy and nervous.", "textHi": "बदतर, क्योंकि मेरी हताशा मुझे आक्रामक और नर्वस बनाती है।", "feedback": "Correct. Detachment ('I will offer value regardless of if they buy') actually often leads to better sales.", "feedbackHi": "सही। अनासक्ति ('मैं मूल्य प्रदान करूंगा भले ही वे खरीदें या नहीं') वास्तव में अक्सर बेहतर बिक्री की ओर ले जाती है।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_2_5", "reflectionPrompt", 5, {
            "prompt": "Where are you 'gripping' the bat too tight? Where can you relax into the action?",
            "promptHi": "आप बल्ले को कहाँ बहुत जोर से 'पकड़' रहे हैं? आप कहाँ कार्रवाई में आराम कर सकते हैं?",
            "krishnaWisdom": "Relaxed focus is stronger than tense effort."
        }, xp=20),
    ]

    # Placeholder for 2.3.2 Unshakable Mind (already had some content but had a placeholder q?)
    # existing unit2.json had q_2_3_2_placeholder. Let's fix.
    
    q_unshakable = [
        create_question("lesson_2_3_2", "scenarioChallenge", 1, {
            "scenarioTitle": "The Rollercoaster",
            "scenarioTitleHi": "रोलरकोस्टर",
            "scenario": "Life gives you a promotion on Monday and a flat tire on Tuesday. How does your mind react?",
            "scenarioHi": "जीवन आपको सोमवार को पदोन्नति देता है और मंगलवार को टायर पंचर। आपका मन कैसे प्रतिक्रिया करता है?",
            "options": [
               {"text": "I ride the highs and lows screaming.", "textHi": "मैं चिल्लाते हुए उतार-चढ़ाव की सवारी करता हूं।", "feedback": "Exhausting.", "feedbackHi": "थकाऊ।", "isOptimal": False},
               {"text": "I maintain an inner equilibrium.", "textHi": "मैं एक आंतरिक संतुलन बनाए रखता हूं।", "feedback": "This is Sthitaprajna stability.", "feedbackHi": "यह स्थितप्रज्ञ स्थिरता है।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_3_2", "storyCard", 2, {
            "title": "The Ocean and the Rivers",
            "titleHi": "सागर और नदियां",
            "story": "Krishna compares the wise mind to the ocean. Rivers (desires/events) flow into it constantly. But the ocean does not overflow; it remains deep and still. The undisturbed person is not one who has no desires, but one who is not disturbed by the flow of desires.",
            "storyHi": "कृष्ण बुद्धिमान मन की तुलना सागर से करते हैं। नदियां (इच्छाएं/घटनाएं) उसमें लगातार बहती रहती हैं। लेकिन सागर उफनता नहीं है; वह गहरा और स्थिर रहता है। अव्यवस्थित व्यक्ति वह नहीं है जिसकी कोई इच्छा नहीं है, बल्कि वह है जो इच्छाओं के प्रवाह से विचलित नहीं होता है।",
            "krishnaMessage": "Peace is not an empty room; it is a calm heart in a crowded room."
        }, xp=10),
         create_question("lesson_2_3_2", "multipleChoice", 3, {
            "questionText": "What harms the wise person's peace?",
            "questionTextHi": "बुद्धिमान व्यक्ति की शांति को क्या नुकसान पहुंचाता है?",
            "options": ["Bad weather", "Insults", "Nothing", "Loud noises"],
            "optionsHi": ["खराब मौसम", "अपमान", "कुछ नहीं", "तेज आवाजें"],
            "correctAnswerIndex": 2,
            "explanation": "For the truly established soul (Prajahati), external events cannot shake their inner joy.",
            "explanationHi": "सच्ची स्थापित आत्मा (प्रजहाति) के लिए, बाहरी घटनाएं उनके आंतरिक आनंद को नहीं हिला सकतीं।",
            "realLifeApplication": "Aim to be weather-proof."
        }),
        create_question("lesson_2_3_2", "scenarioChallenge", 4, {
            "scenarioTitle": "The Bad Review",
            "scenarioTitleHi": "बुरी समीक्षा",
            "scenario": "Someone leaves a nasty comment on your post. You feel the heat rise in your chest. What do you do?",
            "scenarioHi": "कोई आपकी पोस्ट पर भद्दी टिप्पणी करता है। आप अपनी छाती में गर्मी बढ़ती हुई महसूस करते हैं। आप क्या करते हैं?",
            "options": [
               {"text": "Reply with insults.", "textHi": "अपमान के साथ जवाब दें।", "feedback": "Reactive.", "feedbackHi": "प्रतिक्रियाशील।", "isOptimal": False},
               {"text": "Observe the anger reaction, breathe, and let it pass without acting on it.", "textHi": "क्रोध की प्रतिक्रिया का निरीक्षण करें, सांस लें, और उस पर कार्रवाई किए बिना उसे गुजरने दें।", "feedback": "Mastery.", "feedbackHi": "महारत।", "isOptimal": True}
            ]
        }),
         create_question("lesson_2_3_2", "reflectionPrompt", 5, {
            "prompt": "What triggers you instantly? What if you decided today that this trigger no longer has permission to control you?",
            "promptHi": "आपको तुरंत क्या ट्रिगर करता है? क्या होगा यदि आपने आज फैसला किया कि इस ट्रिगर को अब आपको नियंत्रित करने की अनुमति नहीं है?",
            "krishnaWisdom": "He who is master of his impulses is the true Yogi."
        }, xp=20),
    ]

    # Placeholders for 2.4.2 and 2.4.3
    # 2.4.2 No Peace Without Focus (needs q replacement)
    q_no_peace = [
        create_question("lesson_2_4_2", "scenarioChallenge", 1, {
            "scenarioTitle": "The Scattered Mind",
            "scenarioTitleHi": "बिखरा हुआ मन",
            "scenario": "You try to meditate but check your watch every 30 seconds. Are you at peace?",
            "scenarioHi": "आप ध्यान करने की कोशिश करते हैं लेकिन हर 30 सेकंड में अपनी घड़ी चेक करते हैं। क्या आप शांत हैं?",
            "options": [{"text": "No.", "textHi": "नहीं।", "feedback": "Where there is no concentration, there is no peace.", "feedbackHi": "जहां एकाग्रता नहीं है, वहां शांति नहीं है।", "isOptimal": True}]
        }), # Simplified for brevity in script
        create_question("lesson_2_4_2", "storyCard", 2, {
            "title": "Nasti Buddhir Ayuktasya",
            "titleHi": "नास्ति बुद्धिरयुक्तस्य",
            "story": "Krishna states plainly: 'For the uncontrolled, there is no wisdom, and no meditation. For the unmeditative, there is no peace. And for the peaceless, how can there be happiness?' Focus -> Peace -> Happiness. The order matters.",
            "storyHi": "कृष्ण स्पष्ट रूप से कहते हैं: 'असंयमित व्यक्ति के लिए न तो ज्ञान है, और न ही ध्यान। ध्यान रहित व्यक्ति के लिए शांति नहीं है। और अशांत व्यक्ति के लिए सुख कैसे हो सकता है?' एकाग्रता -> शांति -> सुख। क्रम मायने रखता है।",
            "krishnaMessage": "Happiness is a byproduct of a peaceful, focused mind."
        }, xp=10),
        create_question("lesson_2_4_2", "multipleChoice", 3, {
            "questionText": "Can you be happy without peace?",
            "questionTextHi": "क्या आप शांति के बिना खुश रह सकते हैं?",
            "options": ["Yes, if I have money", "No", "Maybe", "Only on weekends"],
            "optionsHi": ["हाँ, अगर मेरे पास पैसा है", "नहीं", "शायद", "केवल सप्ताहांत पर"],
            "correctAnswerIndex": 1,
            "explanation": "Ashantasya kutah sukham? How can the peaceless be happy? Agitation kills joy.",
            "explanationHi": "अशांतस्य कुतः सुखम्? अशांत व्यक्ति सुखी कैसे हो सकता है? उत्तेजना खुशी को मार देती है।",
            "realLifeApplication": "Prioritize peace of mind over excitement."
        }),
        create_question("lesson_2_4_2", "scenarioChallenge", 4, {
            "scenarioTitle": "Chasing the Next High",
            "scenarioTitleHi": "अगले नशे का पीछा",
            "scenario": "You go from party to party seeking fun, but feel empty when alone. Why?",
            "scenarioHi": "आप मजे की तलाश में पार्टी-दर-पार्टी जाते हैं, लेकिन अकेले होने पर खाली महसूस करते हैं। क्यों?",
            "options": [
               {"text": "Refusal to sit with oneself blocks peace.", "textHi": "खुद के साथ बैठने से इनकार शांति को रोकता है।", "feedback": "True happiness requires the ability to sit still.", "feedbackHi": "सच्ची खुशी के लिए शांत बैठने की क्षमता की आवश्यकता होती है।", "isOptimal": True},
               {"text": "Bad parties.", "textHi": "बुरी पार्टियां।", "feedback": "Unlikely.", "feedbackHi": "इसकी संभावना कम है।", "isOptimal": False}
            ]
        }),
        create_question("lesson_2_4_2", "reflectionPrompt", 5, {
            "prompt": "When was the last time you felt truly peaceful? What were you doing (or NOT doing)?",
            "promptHi": "पिछली बार आपने कब वास्तव में शांति महसूस की थी? आप क्या कर रहे थे (या क्या नहीं कर रहे थे)?",
            "krishnaWisdom": "Control the senses, and peace follows."
        }, xp=20)
    ]

    # 2.4.3 Like the Ocean (needs q replacement)
    q_ocean = [
        create_question("lesson_2_4_3", "scenarioChallenge", 1, {
            "scenarioTitle": "Desires Entering",
            "scenarioTitleHi": "इच्छाओं का प्रवेश",
            "scenario": "Imagine desires are rivers flowing into you. 'I want pizza,' 'I want fame,' 'I want sleep.' Do you flood?",
            "scenarioHi": "कल्पना कीजिए कि इच्छाएं आप में बहने वाली नदियां हैं। 'मुझे पिज्जा चाहिए,' 'मुझे शोहरत चाहिए,' 'मुझे नींद चाहिए।' क्या आप बाढ़ में डूब जाते हैं?",
            "options": [
               {"text": "I chase every river upstream.", "textHi": "मैं हर नदी का ऊपर की ओर पीछा करता हूं।", "feedback": "Exhausting.", "feedbackHi": "थकाऊ।", "isOptimal": False},
               {"text": "I contain them like the ocean.", "textHi": "मैं उन्हें सागर की तरह समाहित करता हूं।", "feedback": "You remain filled and unmoving (Acalapratishtham).", "feedbackHi": "आप भरे हुए और अचल (अचलप्रतिष्ठम्) रहते हैं।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_4_3", "storyCard", 2, {
            "title": "Acalapratishtham",
            "titleHi": "अचलप्रतिष्ठम्",
            "story": "The Gita ends this chapter with a promise of 'Brahmi-sthitih'—the state of the Divine. One who lives like the ocean, ignoring the 'this is mine' and 'I am the doer' thoughts, attains peace. Even at the moment of death, such a person is liberated.",
            "storyHi": "गीता इस अध्याय का अंत 'ब्राह्मी-स्थिति'—दिव्य स्थिति—के वादे के साथ करती है। जो सागर की तरह जीता है, 'यह मेरा है' और 'मैं कर्ता हूं' विचारों की अनदेखी करता है, वह शांति प्राप्त करता है। मृत्यु के क्षण में भी, ऐसा व्यक्ति मुक्त हो जाता है।",
            "krishnaMessage": "Live in the world, but don't let the world disturb your depths."
        }, xp=10),
         create_question("lesson_2_4_3", "multipleChoice", 3, {
            "questionText": "What leads to peace according to the final verses?",
            "questionTextHi": "अंतिम श्लोकों के अनुसार शांति की ओर क्या ले जाता है?",
            "options": ["Fulfilling all desires", "Abandoning all desires", "Talking about desires", "Hiding desires"],
            "optionsHi": ["सभी इच्छाओं को पूरा करना", "सभी इच्छाओं को त्यागना", "इच्छाओं के बारे में बात करना", "इच्छाओं को छिपाना"],
            "correctAnswerIndex": 1,
            "explanation": "Vihaya kaman (abandoning desires) and living without 'mineness' (nirmama) leads to peace.",
            "explanationHi": "विहाय कामान् (इच्छाओं को त्यागकर) और 'ममत्व' (निर्मम) के बिना जीने से शांति मिलती है।",
            "realLifeApplication": "Try saying 'I desire nothing right now' and feel the immediate relief."
        }),
        create_question("lesson_2_4_3", "scenarioChallenge", 4, {
            "scenarioTitle": "Mine vs. Ours",
            "scenarioTitleHi": "मेरा बनाम हमारा",
            "scenario": "You fight over a parking spot. 'It's MINE!' What is the root cause of this stress?",
            "scenarioHi": "आप पार्किंग स्थल के लिए लड़ते हैं। 'यह मेरा है!' इस तनाव का मूल कारण क्या है?",
            "options": [
               {"text": "The other driver.", "textHi": "दूसरा ड्राइवर।", "feedback": "External blame.", "feedbackHi": "बाहरी दोष।", "isOptimal": False},
               {"text": "My sense of possessiveness (Nirmama).", "textHi": "मेरा स्वामित्व का भाव (निर्मम)।", "feedback": "Correct. The spot is just asphalt.", "feedbackHi": "सही। जगह सिर्फ डामर है।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_4_3", "reflectionPrompt", 5, {
            "prompt": "Take a deep breath. Release the need for anything to be different than it is right now. That is peace.",
            "promptHi": "गहरी सांस लें। किसी भी चीज़ के अभी जैसी है उससे अलग होने की आवश्यकता को छोड़ दें। वही शांति है।",
            "krishnaWisdom": "This is the state of Brahman. Having attained it, one is not deluded."
        }, xp=20)
    ]
    
    # --- Assembly ---
    
    # Update Section 2.1
    # Existing lessons: 2.1.1, 2.1.2, 2.1.3. Add 2.1.4
    # We should iterate through data['lessons'] and keep those in sec 2.1, then append 2.1.4
    
    lessons = data['lessons']
    questions = data['questions']
    
    # Filter out existing placeholders from questions to avoid dupes/garbage
    placeholders_to_remove = ["q_2_2_1_new_placeholder", "q_2_2_2_new_placeholder", "q_2_2_3_placeholder", "q_2_3_2_placeholder", "q_2_4_2_placeholder", "q_2_4_3_placeholder"]
    questions = [q for q in questions if q['questionId'] not in placeholders_to_remove]
    
    # Add new questions
    questions.extend(q_invincible)
    questions.extend(q_focus)
    questions.extend(q_anxiety_replace)
    questions.extend(q_unshakable)
    questions.extend(q_no_peace)
    questions.extend(q_ocean)
    
    # Now rebuild lessons list
    # We want to insert the new lessons in the correct order and re-number everything
    
    # Current lessons map by ID to easy access
    lesson_map = {l['id']: l for l in lessons}
    
    # Rename "Why Grieve" (lesson_2_2_1) to "The Warrior's Duty"
    if "lesson_2_2_1" in lesson_map:
        l = lesson_map["lesson_2_2_1"]
        l["lessonName"] = "The Warrior's Duty"
        l["lessonNameHi"] = "योद्धा का कर्तव्य"
        l["shlokasCovered"] = [31, 32, 33, 34, 35, 36, 37]
        # We need to ensure questions for this lesson match the new theme? 
        # Actually existing questions for 2.2.1 were "Why Grieve" placeholders or generic.
        # Let's check existing questions for 2.2.1 in the file... 
        # In unit2.json supplied: 
        # q_2_2_1_new_placeholder was there. We replaced it with `q_anxiety_replace` but `q_anxiety_replace` was assigned to lesson_2_2_5 in my code above?
        # WAIT. In the file, lesson_2_2_1 used q_2_2_1_new_placeholder.
        # But in my code above I assigned q_anxiety_replace to lesson_2_2_5.
        # And I assigned q_invincible to lesson_2_1_4.
        
        # We need to map questions to the correct lesson IDs.
        # Let's restructure the lesson list explicitly.
    
    new_lesson_order = [
        "lesson_2_1_1", # Indestructible Soul
        "lesson_2_1_2", # Eternal Witness
        "lesson_2_1_3", # Changing Clothes
        "lesson_2_1_4", # NEW: Invincible Self
        
        "lesson_2_2_1", # Renamed: Warrior's Duty. (Was Why Grieve)
        "lesson_2_2_2", # Science of Action
        "lesson_2_2_focus", # NEW: Focus vs Distraction
        "lesson_2_2_3", # Right to Work
        "lesson_2_2_4", # Yoga is Skill
        "lesson_2_2_5", # Free from Anxiety
        
        "lesson_2_3_1", # Defining Wisdom
        "lesson_2_3_2", # Unshakable Mind
        "lesson_2_3_3", # Turtle Technique
        
        "lesson_2_4_1", # Ladder of Ruin
        "lesson_2_4_2", # No Peace without Focus
        "lesson_2_4_3", # Like the Ocean
    ]
    
    final_lessons = []
    
    # Helper to find lesson or use new object
    for i, lid in enumerate(new_lesson_order):
        l_obj = None
        if lid == "lesson_2_1_4":
            l_obj = lesson_invincible
        elif lid == "lesson_2_2_focus":
            l_obj = lesson_focus
        else:
            l_obj = lesson_map.get(lid)
        
        if l_obj:
            l_obj['order'] = i + 1
            l_obj['prerequisite'] = new_lesson_order[i-1] if i > 0 else None
            # Ensure ID consistency just in case
            if lid == "lesson_2_2_focus":
                l_obj['id'] = f"lesson_2_2_focus" # Keep logic simple
            
            final_lessons.append(l_obj)

    # Now we need to make sure the Questions have the matching LessonIDs
    # New questions defined above have:
    # lesson_2_1_4 -> matches
    # lesson_2_2_focus -> matches
    # lesson_2_2_5 -> matches existing ID
    # lesson_2_3_2 -> matches existing ID
    # lesson_2_4_2 -> matches existing ID
    # lesson_2_4_3 -> matches existing ID
    
    # What about lesson_2_2_1 (Warrior's Duty)? We need questions for it.
    # Existing questions for 2.2.1 in JSON were "q_2_2_1_...".
    # Wait, in the VIEWED file, lesson 2.2.1 had "q_2_2_1_new_placeholder".
    # I replaced "q_2_2_1_new_placeholder" with remove list.
    # So lesson 2.2.1 currently has NO questions unless I add them.
    # I should add questions for Warrior's Duty.
    
    q_warrior = [
        create_question("lesson_2_2_1", "scenarioChallenge", 1, {
            "scenarioTitle": "The Unpopular Choice",
            "scenarioTitleHi": "अलोकप्रिय विकल्प",
            "scenario": "You have to make a decision that is right but will make people angry. You face 'social disgrace'. What do you do?",
            "scenarioHi": "आपको एक ऐसा निर्णय लेना है जो सही है लेकिन लोगों को नाराज करेगा। आप 'सामाजिक अपमान' का सामना करते हैं। आप क्या करते हैं?",
            "options": [
                {"text": "Avoid it to be liked.", "textHi": "पसंद किए जाने के लिए इससे बचें।", "feedback": "Krishna warns Arjuna that running away brings infamy worse than death.", "feedbackHi": "कृष्ण अर्जुन को चेतावनी देते हैं कि भागने से मौत से भी बदतर बदनामी होती है।", "isOptimal": False},
                {"text": "Do my duty regardless of opinion.", "textHi": "राय की परवाह किए बिना अपना कर्तव्य करें।", "feedback": "Correct. Swadharma (own duty) comes first.", "feedbackHi": "सही। स्वधर्म (अपना कर्तव्य) पहले आता है।", "isOptimal": True}
            ]
        }),
        create_question("lesson_2_2_1", "storyCard", 2, {
            "title": "Worse Than Death",
            "titleHi": "मौत से भी बदतर",
            "story": "Arjuna thought running away was noble. Krishna corrects him: 'People will speak of your everlasting dishonor; and for one who has been honored, dishonor is worse than death.' (2.34). Doing your duty isn't just about fighting; it's about integrity.",
            "storyHi": "अर्जुन को लगा कि भागना नेक काम है। कृष्ण उसे सुधारते हैं: 'लोग तुम्हारे अनंत अपमान की बात करेंगे; और सम्मानित व्यक्ति के लिए अपमान मृत्यु से भी बदतर है।' (2.34)। अपना कर्तव्य करना केवल लड़ने के बारे में नहीं है; यह अखंडता के बारे में है।",
            "krishnaMessage": "Integrity means standing your ground when it counts."
        }, xp=10),
         create_question("lesson_2_2_1", "multipleChoice", 3, {
            "questionText": "If you abandon your duty due to fear, what is the result?",
            "questionTextHi": "यदि आप भय के कारण अपने कर्तव्य का त्याग करते हैं, तो इसका परिणाम क्या होगा?",
            "options": ["Peace", "Sin and Dishonor", "Happiness", "Freedom"],
            "optionsHi": ["शांति", "पाप और अपमान", "खुशी", "स्वतंत्रता"],
            "correctAnswerIndex": 1,
            "explanation": "Krishna is harsh here: abandoning duty (Swadharma) brings sin (Papa) and loss of reputation (Akirti).",
            "explanationHi": "कृष्ण यहाँ कठोर हैं: कर्तव्य (स्वधर्म) का त्याग करने से पाप और प्रतिष्ठा की हानि (अकीर्ति) होती है।",
            "realLifeApplication": "Don't drop your responsibilities just because they get hard."
        }),
        create_question("lesson_2_2_1", "reflectionPrompt", 5, {
            "prompt": "Is there a responsibility you are avoiding because you are afraid of what people will say?",
            "promptHi": "क्या कोई ऐसी जिम्मेदारी है जिससे आप बच रहे हैं क्योंकि आप डरते हैं कि लोग क्या कहेंगे?",
            "krishnaWisdom": "Do your duty. Hesitation is the enemy."
        }, xp=20)
    ]
    
    questions.extend(q_warrior)

    data['lessons'] = final_lessons
    data['questions'] = questions
    
    with open(UNIT2_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        
    print("Unit 2 Refined Successfully!")

if __name__ == "__main__":
    main()
