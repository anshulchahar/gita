import json
import os

CONTENT_DIR = "../../content"

# Data for Chapters 3-18 (Sections and Lessons)
# Structure: UnitNum -> List of Sections. Each Section -> {"name": str, "lessons": [str]}
THEMATIC_DATA = {
    3: [ # Karma Yoga
        {"name": "The Necessity of Action", "lessons": ["Why We Must Act", "The Trap of Inaction", "False Renunciation"]},
        {"name": "The Wheel of Sacrifice", "lessons": ["Yajna: The Cycle of Life", "Nourishing the Gods", "Eating Sin"]},
        {"name": "Leading by Example", "lessons": ["The Wise Leader", "Detached Action", "Preventing Confusion"]},
        {"name": "Overcoming Desire", "lessons": ["The Eternal Enemy", "The Seat of Desire", "Slaying the Foe"]}
    ],
    4: [ # Jnana Karma Sanyasa Yoga
        {"name": "Divine History", "lessons": ["The Lost Sun Yoga", "Krishna's Birth", "Avatar: The Purpose"]},
        {"name": "Action in Inaction", "lessons": ["Who is a Doer?", "The Fire of Knowledge", "Independent of Results"]},
        {"name": "The Power of Sacrifice", "lessons": ["Types of Yajna", "Knowledge as Sacrifice", "The Sword of Wisdom"]},
        {"name": "Faith and Doubt", "lessons": ["The Power of Faith", "Destroying Doubt", "The Ultimate Goal"]}
    ],
    5: [ # Karma Sanyasa Yoga
        {"name": "Renunciation vs. Action", "lessons": ["Which is Better?", "Children vs. Wise", "The Goal is One"]},
        {"name": "The Lotus Leaf", "lessons": ["Untouched by Sin", "Body, Mind, Intellect", "Removing Impurities"]},
        {"name": "The Equal Vision", "lessons": ["Looking with Equality", "Beyond Dualities", "The Joy Within"]},
        {"name": "Formula for Peace", "lessons": ["Mastering Anger", "Freedom Here and Now", "The Friend of All"]}
    ],
    6: [ # Dhyana Yoga
        {"name": "The Meditative State", "lessons": ["Who is a Sannyasi?", "Elevating the Self", "Friend or Foe?"]},
        {"name": "Practice of Meditation", "lessons": ["The Sacred Spot", "Holding the Body", "The Vow of Celibacy"]},
        {"name": "Mind Control", "lessons": ["The Restless Mind", "Abhyasa and Vairagya", "Seeing Unity"]},
        {"name": "The Fallen Yogi", "lessons": ["Is All Lost?", "The Path of Return", "The Greatest Yogi"]}
    ],
    7: [ # Jnana Vijnana Yoga
        {"name": "Matter and Spirit", "lessons": ["Eightfold Nature", "The Living Entity", "The Sutra on Pearls"]},
        {"name": "Divine Manifestations", "lessons": ["Essence of Water", "Light of the Sun", "Seed of Beings"]},
        {"name": "The Four Types", "lessons": ["The Pious Seekers", "The Wise Devotee", "Faith in Demigods"]},
        {"name": "Overcoming Illusion", "lessons": ["Maya's Power", "Knowing Me Fully", "Freedom from Delusion"]}
    ],
    8: [ # Aksara Brahma Yoga
        {"name": "Seven Great Questions", "lessons": ["What is Brahman?", "What is Karma?", "Thinking at Death"]},
        {"name": "The Art of Dying", "lessons": ["Remembering Him", "Closing the Gates", "Om the Syllable"]},
        {"name": "The Material Worlds", "lessons": ["From Brahma to Worm", "Day and Night of Brahma", "The Cyclic Creation"]},
        {"name": "The Eternal Abode", "lessons": ["Beyond the Unmanifest", "The Supreme Destination", "Light and Dark Paths"]}
    ],
    9: [ # Raja Vidya Raja Guhya Yoga
        {"name": "The Royal Secret", "lessons": ["King of Knowledge", "Direct Perception", "Faithlessness"]},
        {"name": "Universal Sustainer", "lessons": ["Pervading the Universe", "Creator and Destroyer", "The Father and Mother"]},
        {"name": "Worship and Care", "lessons": ["The Leaf and Flower", "Yoga-Kshemam", "Worshipping Others"]},
        {"name": "Redemption for All", "lessons": ["Even the Wicked", "Women and Sudras", "Focus Your Mind"]}
    ],
    10: [ # Vibhuti Yoga
        {"name": "Source of Everything", "lessons": ["Origin of Gods", "The Seven Sages", "Knowing the Glories"]},
        {"name": "The Chatur-Shloki", "lessons": ["The Seed Verse", "Lamp of Knowledge", "Arjuna's Acceptance"]},
        {"name": "Divine Opulences I", "lessons": ["Vishnu among Adityas", "Marichi among Winds", "Moon among Stars"]},
        {"name": "Divine Opulences II", "lessons": ["Lion among Beasts", "Rama among Warriors", "Ganga among Rivers", "The Gambling of Cheats"]}
    ],
    11: [ # Visvarupa Darsana Yoga
        {"name": "Request for Vision", "lessons": ["Arjuna's Desire", "Divine Eyes", "Sanjaya's Description"]},
        {"name": "The Cosmic Form", "lessons": ["Many Mouths and Eyes", "Blazing Like Suns", "The Terrified Worlds"]},
        {"name": "Time the Destroyer", "lessons": ["Devouring the Warriors", "I Am Time", "Fight as an Instrument"]},
        {"name": "The Gentle Form", "lessons": ["Arjuna's Apology", "Four-Armed Form", "Two-Armed Form"]}
    ],
    12: [ # Bhakti Yoga
        {"name": "Personal vs. Impersonal", "lessons": ["Which is Better?", "Fixing the Mind", "The Difficult Path"]},
        {"name": "Ladder of Practice", "lessons": ["If You Cannot Focus", "Work for Me", "Renounce Results"]},
        {"name": "Qualities of a Devotee I", "lessons": ["Non-Envious", "Equal in Pain/Pleasure", "Determined"]},
        {"name": "Qualities of a Devotee II", "lessons": ["Not Causing Fear", "Pure and Expert", "Dear to Me"]}
    ],
    13: [ # Ksetra Ksetrajna Vibhaga Yoga
        {"name": "Field and Knower", "lessons": ["The Body (Field)", "The Soul (Knower)", "The Super-Knower"]},
        {"name": "Process of Knowledge", "lessons": ["Humility and Non-violence", "Detachment", "Constant Devotion"]},
        {"name": "The Object of Knowledge", "lessons": ["Hands and Feet Everywhere", "Inside and Outside", "The Light of Lights"]},
        {"name": "Prakriti and Purusha", "lessons": ["Cause and Effect", "Witness and Permitter", "Seeing with Eye of Knowledge"]}
    ],
    14: [ # Gunatraya Vibhaga Yoga
        {"name": "The Three Gunas", "lessons": ["Sattva: Purity", "Rajas: Passion", "Tamas: Ignorance"]},
        {"name": "Effects of Gunas", "lessons": ["Binding the Soul", "Results of Actions", "Gunas at Death"]},
        {"name": "Transcending Gunas", "lessons": ["The Neutral Witness", "Serving with Love", "Signs of Transcendance"]},
        {"name": "Basis of Brahman", "lessons": ["Unfailing Yoga", "I Am The Basis", "Eternal Dharma"]}
    ],
    15: [ # Purusottama Yoga
        {"name": "The Banyan Tree", "lessons": ["Roots Above", "Cutting the Tree", "Seeking the Base"]},
        {"name": "Transmigration", "lessons": ["Dragging the Senses", "Taking a New Body", "The Eye of Wisdom"]},
        {"name": "The Supreme Splendor", "lessons": ["Sun and Moon", "Digestive Fire", "Knower of Vedas"]},
        {"name": "The Three Doers", "lessons": ["Fallible", "Infallible", "The Supreme Person"]}
    ],
    16: [ # Daivasura Sampad Vibhaga Yoga
        {"name": "Divine Qualities", "lessons": ["Fearlessness", "Charity", "Austerity", "Non-violence"]},
        {"name": "Demonic Qualities", "lessons": ["Arrogance", "Anger", "Ignorance", "The Atheistic View"]},
        {"name": "Destiny of the Demonic", "lessons": ["Bound by Desires", "Accumulating Wealth", "Falling into Hell"]},
        {"name": "The Three Gates", "lessons": ["Lust, Anger, Greed", "Escaping Darkness", "Following Scripture"]}
    ],
    17: [ # Sraddhatraya Vibhaga Yoga
        {"name": "Three Types of Faith", "lessons": ["Born of Nature", "Worship by Guna", "Violent Austerity"]},
        {"name": "Food and Sacrifice", "lessons": ["Foods in Modes", "Yajna in Modes", "Tapas of Body/Speech/Mind"]},
        {"name": "Charity in Modes", "lessons": ["Charity in Sattva", "Charity in Rajas", "Charity in Tamas"]},
        {"name": "Om Tat Sat", "lessons": ["Designating Brahman", "Acts of Sacrifice", "Asat (False) Acts"]}
    ],
    18: [ # Moksha Sanyasa Yoga
        {"name": "Renunciation Defined", "lessons": ["Sannyasa vs Tyaga", "Acts Not to Abandon", "Three Kinds of Tyaga"]},
        {"name": "Causes of Action", "lessons": ["Five Factors", "The Non-Doer", "Knowledge, Action, Doer in Modes"]},
        {"name": "Intellect and Resolve", "lessons": ["Buddhi in Modes", "Dhriti in Modes", "Happiness in Modes"]},
        {"name": "Perfection", "lessons": ["Duties by Nature", "Worshipping Through Work", "Becoming Brahman", "Surrender to Me"]}
    ]
}

def fix_unit(unit_num):
    filename = f"unit{unit_num}.json"
    filepath = os.path.join(CONTENT_DIR, filename)
    
    if not os.path.exists(filepath):
        print(f"Skipping {filename} (not found)")
        return

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        return

    # Get thematic data
    themes = THEMATIC_DATA.get(unit_num)
    if not themes:
        print(f"No thematic data for Unit {unit_num}")
        return

    print(f"Fixing Unit {unit_num}...")

    # Update Sections
    sections = data.get('sections', [])
    for i, section in enumerate(sections):
        if i < len(themes):
            theme = themes[i]
            section["sectionName"] = theme["name"]
            # Generate Hindi Name (Placeholder or use translation API if available, 
            # but for now we'll just keep the structure or English to avoid bad translation, 
            # or maybe just append '(Hi)' to indicate to user it needs translation?)
            # The prompt script used "Section X Name", we will replace it.
            # Ideally we would have Hindi in the map. 
            # For this task, English is the priority requested.
            section["sectionNameHi"] = f"{theme['name']} (Hindi)" # Placeholder for manual trans later
            section["keyTeaching"] = f"Understand: {theme['name']}"

    # Update Lessons
    lessons = data.get('lessons', [])
    # We need to map lessons to sections. 
    # The generated lessons are sequential.
    # In generate_content.py, we generated 3 lessons per section.
    # So lesson 0,1,2 -> Section 1. Lesson 3,4,5 -> Section 2.
    
    lesson_idx = 0
    for i, section in enumerate(sections):
        if i >= len(themes): break
        
        theme_lessons = themes[i]["lessons"]
        # Find lessons belonging to this section
        section_id = section["id"]
        lessons_in_sec = [l for l in lessons if l["sectionId"] == section_id]
        
        for j, lesson in enumerate(lessons_in_sec):
            if j < len(theme_lessons):
                lesson["lessonName"] = theme_lessons[j]
                lesson["lessonNameHi"] = f"{theme_lessons[j]} (Hindi)"
            else:
                # Fallback if we have more generated lessons than theme titles
                lesson["lessonName"] = f"Advanced {section['sectionName']} {j+1}"
                
            # Update 'description' or other metadata if necessary? No 'description' in lesson model usually shown 
            
    # Save back
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f"  ✅ Updated {filename}")

def main():
    print("Fixing Titles for Units 3-18...")
    for i in range(3, 19):
        fix_unit(i)
    print("Done!")

if __name__ == "__main__":
    main()
