import Foundation

enum PregnancyTrimester: String {
    case first
    case second
    case third

    var displayName: String {
        switch self {
        case .first: "First Trimester"
        case .second: "Second Trimester"
        case .third: "Third Trimester"
        }
    }

    var weekRange: String {
        switch self {
        case .first: "Weeks 1–12"
        case .second: "Weeks 13–26"
        case .third: "Weeks 27–40"
        }
    }
}

enum PregnancyCalculator {

    struct PregnancyPosition {
        let week: Int           // 1-40+
        let day: Int            // day within the week (1-7)
        let trimester: PregnancyTrimester
        let dueDate: Date
        let daysUntilDue: Int
        let totalDays: Int      // days pregnant
    }

    static func currentPosition(pregnancyStart: Date, on date: Date = Date()) -> PregnancyPosition {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: pregnancyStart)
        let today = calendar.startOfDay(for: date)

        let totalDays = max(0, calendar.dateComponents([.day], from: start, to: today).day ?? 0)
        let week = (totalDays / 7) + 1
        let dayInWeek = (totalDays % 7) + 1

        let trimester: PregnancyTrimester
        if week <= 12 {
            trimester = .first
        } else if week <= 26 {
            trimester = .second
        } else {
            trimester = .third
        }

        let dueDate = calendar.date(byAdding: .day, value: 280, to: start) ?? start
        let daysUntilDue = max(0, calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0)

        return PregnancyPosition(
            week: week,
            day: dayInWeek,
            trimester: trimester,
            dueDate: dueDate,
            daysUntilDue: daysUntilDue,
            totalDays: totalDays
        )
    }

    /// Baby size comparison by week
    static func babySize(week: Int) -> (size: String, length: String, weight: String) {
        switch week {
        case 1...4:   return ("a poppy seed", "< 1 mm", "< 1 g")
        case 5:       return ("a sesame seed", "2 mm", "< 1 g")
        case 6:       return ("a lentil", "4 mm", "< 1 g")
        case 7:       return ("a blueberry", "8 mm", "< 1 g")
        case 8:       return ("a raspberry", "1.5 cm", "1 g")
        case 9:       return ("a cherry", "2.3 cm", "2 g")
        case 10:      return ("a strawberry", "3 cm", "4 g")
        case 11:      return ("a fig", "4 cm", "7 g")
        case 12:      return ("a lime", "5.5 cm", "14 g")
        case 13:      return ("a peach", "7 cm", "23 g")
        case 14:      return ("a lemon", "8.5 cm", "43 g")
        case 15:      return ("an apple", "10 cm", "70 g")
        case 16:      return ("an avocado", "12 cm", "100 g")
        case 17:      return ("a pear", "13 cm", "140 g")
        case 18:      return ("a sweet potato", "14 cm", "190 g")
        case 19:      return ("a mango", "15 cm", "240 g")
        case 20:      return ("a banana", "16 cm", "300 g")
        case 21:      return ("a carrot", "27 cm", "360 g")
        case 22:      return ("a papaya", "28 cm", "430 g")
        case 23:      return ("a grapefruit", "29 cm", "500 g")
        case 24:      return ("an ear of corn", "30 cm", "600 g")
        case 25:      return ("a cauliflower", "35 cm", "660 g")
        case 26:      return ("a lettuce head", "36 cm", "760 g")
        case 27:      return ("a cabbage", "37 cm", "875 g")
        case 28:      return ("an aubergine", "38 cm", "1 kg")
        case 29:      return ("a butternut squash", "39 cm", "1.15 kg")
        case 30:      return ("a coconut", "40 cm", "1.3 kg")
        case 31:      return ("a pineapple", "41 cm", "1.5 kg")
        case 32:      return ("a melon", "42 cm", "1.7 kg")
        case 33:      return ("a celery bunch", "44 cm", "1.9 kg")
        case 34:      return ("a cantaloupe", "45 cm", "2.1 kg")
        case 35:      return ("a honeydew melon", "46 cm", "2.4 kg")
        case 36:      return ("a romaine lettuce", "47 cm", "2.6 kg")
        case 37:      return ("a winter melon", "48 cm", "2.9 kg")
        case 38:      return ("a leek bundle", "50 cm", "3.1 kg")
        case 39:      return ("a small watermelon", "51 cm", "3.3 kg")
        case 40:      return ("a watermelon", "51 cm", "3.5 kg")
        default:      return ("fully grown", "~51 cm", "~3.5 kg")
        }
    }

    /// Key development milestone for the current week
    static func developmentMilestone(week: Int) -> String {
        switch week {
        case 1...2:   return "Fertilisation and implantation. The embryo is embedding into the uterine lining."
        case 3:       return "The neural tube is forming — this becomes the brain and spinal cord. Folate is critical now."
        case 4:       return "The heart begins to beat. Blood vessels are forming. The placenta is developing."
        case 5:       return "Arm and leg buds appear. The brain is growing rapidly. The heart now has chambers."
        case 6:       return "Facial features begin: nose, mouth, ears. Fingers start forming. The brain controls first muscle movements."
        case 7:       return "All essential organs have begun to form. Hands and feet have tiny webbed fingers and toes."
        case 8:       return "Baby can now make tiny movements. Bones are beginning to harden. Taste buds are forming."
        case 9:       return "All major organs are in place. Muscles are developing. The embryo is now officially a fetus."
        case 10:      return "Vital organs are functioning. Tiny nails begin forming. Kidneys are producing urine."
        case 11:      return "Bones are hardening. Baby can open and close fists. Tooth buds are forming under the gums."
        case 12:      return "Vocal cords are forming. The digestive system is practising. The risk of miscarriage drops significantly."
        case 13:      return "Welcome to the second trimester. Fingerprints are forming. Baby may start sucking their thumb."
        case 14:      return "Baby's facial muscles are working — squinting, frowning, grimacing. The liver is producing bile."
        case 15:      return "Baby can sense light through closed eyelids. Bones are getting stronger. The body is growing faster than the head now."
        case 16:      return "The skeletal system is developing. Baby's legs are longer than arms now. You may begin to feel flutters."
        case 17:      return "Fat stores begin forming under the skin — vital for temperature regulation after birth."
        case 18:      return "Baby can hear your heartbeat and voice. The nervous system is maturing rapidly. Myelin sheaths are forming."
        case 19:      return "A waxy coating called vernix protects the skin. Sensory development accelerates — brain areas for smell, taste, hearing, sight, and touch are developing."
        case 20:      return "Halfway there. Baby swallows amniotic fluid, practising digestion. You likely feel clear kicks now."
        case 21:      return "Baby's movements become more coordinated. Bone marrow begins producing blood cells."
        case 22:      return "Eyes are formed but irises lack colour. Baby has a sleep-wake cycle. Lungs are developing surfactant."
        case 23:      return "Baby can hear sounds outside the womb. Rapid brain development — DHA is crucial now."
        case 24:      return "The inner ear is fully developed — baby has a sense of balance. Lungs are maturing."
        case 25:      return "Baby responds to your voice. Fat continues accumulating. Hands can fully grasp."
        case 26:      return "Eyes open for the first time. Baby can see light filtering through your belly."
        case 27:      return "Welcome to the third trimester. Baby's brain is very active. Sleep includes REM cycles now."
        case 28:      return "Baby can blink and dream. Lungs are capable of breathing air with medical support."
        case 29:      return "Muscles and lungs are maturing. Baby is getting stronger. Head may turn toward light."
        case 30:      return "Baby's brain is growing rapidly — surface area is increasing with grooves and folds."
        case 31:      return "All five senses are now functional. Baby processes information and tracks light."
        case 32:      return "Toenails and hair are present. Baby practises breathing movements. Bones are fully developed but still soft."
        case 33:      return "Baby's immune system is strengthening. Pupils can constrict and dilate in response to light."
        case 34:      return "The central nervous system and lungs are maturing. Baby is building fat reserves for birth."
        case 35:      return "Kidneys and liver are fully functional. Baby is gaining about 230g per week now."
        case 36:      return "Baby drops lower into the pelvis. The downy lanugo hair starts to shed. Systems are nearly ready."
        case 37:      return "Baby is considered early term. Lungs are nearly mature. Baby is practising swallowing and breathing."
        case 38:      return "Baby's organs are ready for life outside. Brain and lungs continue final maturation."
        case 39:      return "Full term. Baby's brain is still growing rapidly. The last weeks add critical fat and lung surfactant."
        case 40:      return "Due date week. Baby is fully developed and ready. Every extra day adds brain connections and lung strength."
        default:      return "Past due date. Baby is fully developed. Consult your provider about next steps."
        }
    }
}
