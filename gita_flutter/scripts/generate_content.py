import json
import os

# Definition of chapters with metadata provided by user
CHAPTERS = {
    3: {"name": "Karma Yoga", "nameHi": "कर्म योग", "theme": "Action", "icon": "⚡", "color": "#FF6F00", "journey": "journey_1", "difficulty": "intermediate", "shlokas": 43},
    4: {"name": "Jnana Karma Sanyasa Yoga", "nameHi": "ज्ञान कर्म संन्यास योग", "theme": "Knowledge", "icon": "📚", "color": "#1565C0", "journey": "journey_1", "difficulty": "intermediate", "shlokas": 42},
    5: {"name": "Karma Sanyasa Yoga", "nameHi": "कर्म संन्यास योग", "theme": "Renunciation", "icon": "🕊️", "color": "#00695C", "journey": "journey_1", "difficulty": "intermediate", "shlokas": 29},
    6: {"name": "Dhyana Yoga", "nameHi": "ध्यान योग", "theme": "Meditation", "icon": "🔮", "color": "#6A1B9A", "journey": "journey_1", "difficulty": "advanced", "shlokas": 47},
    7: {"name": "Jnana Vijnana Yoga", "nameHi": "ज्ञान विज्ञान योग", "theme": "Divine Knowledge", "icon": "✨", "color": "#C62828", "journey": "journey_2", "difficulty": "intermediate", "shlokas": 30},
    8: {"name": "Aksara Brahma Yoga", "nameHi": "अक्षर ब्रह्म योग", "theme": "The Imperishable Brahman", "icon": "🌌", "color": "#283593", "journey": "journey_2", "difficulty": "advanced", "shlokas": 28},
    9: {"name": "Raja Vidya Raja Guhya Yoga", "nameHi": "राज विद्या राज गुह्य योग", "theme": "Royal Secret", "icon": "👑", "color": "#EF6C00", "journey": "journey_2", "difficulty": "intermediate", "shlokas": 34},
    10: {"name": "Vibhuti Yoga", "nameHi": "विभूति योग", "theme": "Divine Glory", "icon": "🌟", "color": "#F9A825", "journey": "journey_2", "difficulty": "intermediate", "shlokas": 42},
    11: {"name": "Visvarupa Darsana Yoga", "nameHi": "विश्वरूप दर्शन योग", "theme": "Universal Form", "icon": "🌐", "color": "#00838F", "journey": "journey_2", "difficulty": "advanced", "shlokas": 55},
    12: {"name": "Bhakti Yoga", "nameHi": "भक्ति योग", "theme": "Devotion", "icon": "💜", "color": "#8E24AA", "journey": "journey_2", "difficulty": "intermediate", "shlokas": 20},
    13: {"name": "Ksetra Ksetrajna Vibhaga Yoga", "nameHi": "क्षेत्र क्षेत्रज्ञ विभाग योग", "theme": "Field & Knower", "icon": "🌾", "color": "#558B2F", "journey": "journey_3", "difficulty": "advanced", "shlokas": 34},
    14: {"name": "Gunatraya Vibhaga Yoga", "nameHi": "गुणत्रय विभाग योग", "theme": "Three Gunas", "icon": "🎭", "color": "#5D4037", "journey": "journey_3", "difficulty": "advanced", "shlokas": 27},
    15: {"name": "Purusottama Yoga", "nameHi": "पुरुषोत्तम योग", "theme": "Supreme Person", "icon": "🌳", "color": "#1B5E20", "journey": "journey_3", "difficulty": "advanced", "shlokas": 20},
    16: {"name": "Daivasura Sampad Vibhaga Yoga", "nameHi": "दैवासुर सम्पद् विभाग योग", "theme": "Divine & Demonic", "icon": "⚖️", "color": "#BF360C", "journey": "journey_3", "difficulty": "intermediate", "shlokas": 24},
    17: {"name": "Sraddhatraya Vibhaga Yoga", "nameHi": "श्रद्धात्रय विभाग योग", "theme": "Three Faiths", "icon": "🙏", "color": "#4527A0", "journey": "journey_3", "difficulty": "intermediate", "shlokas": 28},
    18: {"name": "Moksha Sanyasa Yoga", "nameHi": "मोक्ष संन्यास योग", "theme": "Liberation", "icon": "🔥", "color": "#FF6F00", "journey": "journey_3", "difficulty": "advanced", "shlokas": 78}
}

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../content")

def generate_lessons(unit_id, section_id, start_lesson_idx, num_lessons, shlokas_per_lesson, difficulty):
    lessons = []
    for i in range(num_lessons):
        lesson_num = start_lesson_idx + i
        lesson_id = f"lesson_{unit_id.split('_')[1]}_{section_id.split('_')[2]}_{lesson_num}"
        
        prereq = None
        if i > 0:
             prereq = f"lesson_{unit_id.split('_')[1]}_{section_id.split('_')[2]}_{lesson_num - 1}"
        elif start_lesson_idx > 1:
             # Link to previous section's last lesson if needed, but for simplicity we'll keep prerequisites within sections or just simple sequential logic if we had global tracking.
             # In unit1.json, prerequisites flow sequentially across sections.
             # For this generation script, we will just set it to None for the first lesson of a section to avoid complexity, or link to the last lesson of previous section if we tracked it.
             # Let's simple chain: if it's the very first lesson of the unit, None. Else 'previous_lesson_id'.
             pass

        lesson = {
            "id": lesson_id,
            "sectionId": section_id,
            "unitId": unit_id,
            "lessonNumber": lesson_num,
            "lessonName": f"Lesson {lesson_num} of Section {section_id.split('_')[2]}",
            "lessonNameHi": f"पाठ {lesson_num} (खंड {section_id.split('_')[2]})",
            "order": lesson_num, # active order within the unit, actually. In unit1 it's 1..12 across sections.
            "estimatedTime": 300,
            "difficulty": difficulty,
            "shlokasCovered": [1, 2], # Placeholder
            "xpReward": 50,
            "prerequisite": None # We will patch this up in a second pass or simple counter
        }
        lessons.append(lesson)
    return lessons

def generate_questions(lesson_id, lesson_order):
    # 5 questions: scenarioChallenge, storyCard, multipleChoice, scenarioChallenge, reflectionPrompt
    questions = []
    types = ["scenarioChallenge", "storyCard", "multipleChoice", "scenarioChallenge", "reflectionPrompt"]
    
    for i, q_type in enumerate(types):
        q_order = i + 1
        q_id = f"q_{lesson_id.split('_')[1]}_{lesson_id.split('_')[2]}_{lesson_id.split('_')[3]}_{q_type}_{q_order}"
        
        content = {}
        if q_type == "scenarioChallenge":
            content = {
                "scenarioTitle": "Practice Scenario",
                "scenarioTitleHi": "अभ्यास परिदृश्य",
                "scenario": "A situation to apply Gita wisdom.",
                "scenarioHi": "गीता ज्ञान लागू करने की स्थिति।",
                "options": [
                    {"text": "Option A (Incorrect)", "textHi": "विकल्प A", "feedback": "Feedback A", "feedbackHi": "प्रतिक्रिया A", "isOptimal": False},
                    {"text": "Option B (Correct)", "textHi": "विकल्प B", "feedback": "Feedback B", "feedbackHi": "प्रतिक्रिया B", "isOptimal": True}
                ]
            }
        elif q_type == "storyCard":
            content = {
                "title": "A Story from the Chapter",
                "titleHi": "अध्याय से एक कहानी",
                "story": "A short story illustrating the lesson.",
                "storyHi": "पाठ को समझाने वाली एक छोटी कहानी।",
                "krishnaMessage": "Core wisdom from the story."
            }
        elif q_type == "multipleChoice":
            content = {
                "questionText": "Question about the lesson?",
                "questionTextHi": "पाठ के बारे में प्रश्न?",
                "options": ["Answer A", "Answer B", "Answer C", "Answer D"],
                "optionsHi": ["उत्तर A", "उत्तर B", "उत्तर C", "उत्तर D"],
                "correctAnswerIndex": 1,
                "explanation": "Why B is correct.",
                "explanationHi": "B क्यों सही है।",
                "realLifeApplication": "Apply this to daily life."
            }
        elif q_type == "reflectionPrompt":
            content = {
                "prompt": "Reflect on how this applies to you.",
                "promptHi": "विचार करें कि यह आप पर कैसे लागू होता है।",
                "guidingQuestions": ["Question 1?", "Question 2?"],
                "krishnaWisdom": "Concluding wisdom."
            }

        questions.append({
            "questionId": q_id,
            "lessonId": lesson_id,
            "type": q_type,
            "order": q_order,
            "xpReward": 10 if q_type == "storyCard" else 25,
            "content": content
        })
    return questions

def main():
    if not os.path.exists(OUTPUT_DIR):
        print(f"Output directory {OUTPUT_DIR} does not exist!")
        return

    for num, meta in CHAPTERS.items():
        unit_id = f"unit_{num}"
        print(f"Generating {unit_id}...")
        
        # Unit Data
        unit_data = {
            "id": unit_id,
            "unitNumber": num,
            "unitName": meta["name"],
            "unitNameHi": meta["nameHi"],
            "chapterNumber": num,
            "theme": meta["theme"],
            "difficulty": meta["difficulty"],
            "icon": meta["icon"],
            "color": meta["color"],
            "description": f"Chapter {num}: {meta['name']} - {meta['theme']}",
            "descriptionHi": f"अध्याय {num}: {meta['nameHi']} - {meta['theme']}",
            "journeyId": meta["journey"],
            "shlokasCovered": f"1-{meta['shlokas']}",
            "shlokaCount": meta["shlokas"]
        }

        # Sections (4 per unit)
        sections = []
        all_lessons = []
        all_questions = []
        
        shlokas_per_section = meta["shlokas"] // 4
        lesson_global_counter = 1
        
        for s in range(1, 5):
            section_id = f"section_{num}_{s}"
            start_shloka = (s-1) * shlokas_per_section + 1
            end_shloka = s * shlokas_per_section if s < 4 else meta["shlokas"]
            
            sections.append({
                "id": section_id,
                "unitId": unit_id,
                "sectionNumber": s,
                "sectionName": f"Section {s} Name",
                "sectionNameHi": f"खंड {s} नाम",
                "shlokaRange": f"{start_shloka}-{end_shloka}",
                "keyTeaching": "Key teaching for this section",
                "order": s
            })
            
            # Lessons (3-5 per section, let's do 3 for simplicity to meet min requirement)
            lessons_in_section = generate_lessons(unit_id, section_id, 1, 3, 2, meta["difficulty"])
            
            # Fix up lesson orders and prerequisites
            for l in lessons_in_section:
                l["order"] = lesson_global_counter
                if lesson_global_counter > 1:
                     # Previous lesson in the global list
                     l["prerequisite"] = all_lessons[-1]["id"]
                else:
                     l["prerequisite"] = None
                
                all_lessons.append(l)
                
                # Questions for this lesson
                qs = generate_questions(l["id"], l["order"])
                all_questions.extend(qs)
                
                lesson_global_counter += 1

        full_json = {
            "unit": unit_data,
            "sections": sections,
            "lessons": all_lessons,
            "questions": all_questions
        }

        output_path = os.path.join(OUTPUT_DIR, f"unit{num}.json")
        with open(output_path, "w", encoding='utf-8') as f:
            json.dump(full_json, f, indent=4, ensure_ascii=False)
            
    print("Generation complete.")

if __name__ == "__main__":
    main()
