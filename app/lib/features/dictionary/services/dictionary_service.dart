import '../models/dictionary_entry.dart';

class DictionaryService {
  static const String _cloudinaryBaseUrl =
      'https://res.cloudinary.com/YOUR_CLOUD_NAME/video/upload/';

  String cloudName = 'dxau89gcg';

  static final List<DictionaryEntry> _entries = [
    DictionaryEntry(
      id: 0,
      label: 'GOOD MORNING',
      description: 'A common greeting used in the morning.',
      signAction:
          'Place fingers of right hand on chin, move hand down to the open palm of the left hand ("Good"). Then, place right hand in the crook of the left elbow and raise the right forearm up ("Morning").',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632227/GOOD_MORNING_0_rntab5.mov',
    ),
    DictionaryEntry(
      id: 1,
      label: 'GOOD AFTERNOON',
      description: 'A common greeting used in the afternoon.',
      signAction:
          'Perform the sign for "Good". Then, with the right arm extended forward, open palm facing down, lower the arm slightly to represent the sun going down.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632213/GOOD_AFTERNOON_0_mxs34k.mov',
    ),
    DictionaryEntry(
      id: 2,
      label: 'GOOD EVENING',
      description: 'A common greeting used in the evening.',
      signAction:
          'Perform the sign for "Good". Then, cross the right wrist over the left wrist, hands curving down, mimicking the sun setting over the horizon.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632225/GOOD_EVENING_0_qprwad.mov',
    ),
    DictionaryEntry(
      id: 3,
      label: 'HELLO',
      description: 'A basic greeting.',
      signAction:
          'Bring the right hand to the forehead with palm facing out, similar to a salute, and move it outward away from the head.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632237/HELLO_0_fbysmc.mov',
    ),
    DictionaryEntry(
      id: 4,
      label: 'HOW ARE YOU',
      description: 'A common phrase used to ask about a person’s well-being.',
      signAction:
          'Place both curved hands with knuckles touching the chest, then twist them outward so palms face up. Point to the other person at the end.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632240/HOW_ARE_YOU_0_gmfrqa.mov',
    ),
    DictionaryEntry(
      id: 5,
      label: 'IM FINE',
      description: 'A common response indicating good health or condition.',
      signAction:
          'Touch the thumb of your open "5-hand" to your chest and tap it twice repeatedly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632241/IM_FINE_0_ur0qyf.mov',
    ),
    DictionaryEntry(
      id: 6,
      label: 'NICE TO MEET YOU',
      description: 'A polite phrase used upon meeting someone.',
      signAction:
          'Slide the right palm over the left palm ("Nice"). Then bring both index fingers together so they meet in the middle ("Meet"). Point to the person ("You").',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632265/NICE_TO_MEET_YOU_0_lud7c4.mov',
    ),
    DictionaryEntry(
      id: 7,
      label: 'THANK YOU',
      description: 'An expression of gratitude.',
      signAction:
          'Touch the fingertips of your open right hand to your chin, then move the hand outward towards the other person.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632302/THANK_YOU_0_lwbylf.mov',
    ),
    DictionaryEntry(
      id: 8,
      label: 'YOURE WELCOME',
      description: 'A polite response to "Thank you."',
      signAction:
          'With the right open hand palm up, swoop the hand inward toward your waist and then outward towards the person.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632330/YOURE_WELCOME_0_ghinyj.mov',
    ),
    DictionaryEntry(
      id: 9,
      label: 'SEE YOU TOMORROW',
      description: 'A common farewell used when planning to meet the next day.',
      signAction:
          'Tap the "V" handshape near the eye ("See"). Point to the person ("You"). Make a thumbs-up shape near the cheek and move it forward ("Tomorrow").',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632285/SEE_YOU_TOMORROW_0_qrvkpf.mov',
    ),
    DictionaryEntry(
      id: 10,
      label: 'UNDERSTAND',
      description: 'To grasp the meaning of information.',
      signAction:
          'Place a closed fist near the side of your forehead, then flick the index finger upward, like a lightbulb turning on.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632314/UNDERSTAND_0_mxwo4l.mov',
    ),
    DictionaryEntry(
      id: 11,
      label: 'DON’T UNDERSTAND',
      description: 'To not grasp the meaning of information.',
      signAction:
          'Perform the sign for "Understand", but shake your head side-to-side (negation) while doing it.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632101/DONT_UNDERSTAND_0_nslopp.mov',
    ),
    DictionaryEntry(
      id: 12,
      label: 'KNOW',
      description: 'To be aware of something.',
      signAction:
          'Tap the fingertips of your bent right hand against the side of your forehead.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632248/KNOW_0_drrnnr.mov',
    ),
    DictionaryEntry(
      id: 13,
      label: 'DON’T KNOW',
      description: 'To not be aware of something.',
      signAction:
          'Touch the forehead with fingertips, then turn the hand outward vigorously while shaking the head.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632099/DONT_KNOW_0_tgtvvb.mov',
    ),
    DictionaryEntry(
      id: 14,
      label: 'NO',
      description:
          'An answer or statement that expresses disagreement or denial.',
      signAction:
          'Tap the index and middle fingers together against the thumb, mimicking a mouth closing.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632268/NO_0_dja5ts.mov',
    ),
    DictionaryEntry(
      id: 15,
      label: 'YES',
      description:
          'An answer or statement that expresses agreement or affirmation.',
      signAction:
          'Make a fist (S-handshape) and bob it up and down like a head nodding.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632327/YES_0_vuibam.mov',
    ),
    DictionaryEntry(
      id: 16,
      label: 'WRONG',
      description: 'Incorrect or not true.',
      signAction:
          'Make a "Y" handshape (thumb and pinky out) and tap the chin with the back of the hand.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632325/WRONG_0_o2v8nc.mov',
    ),
    DictionaryEntry(
      id: 17,
      label: 'CORRECT',
      description: 'Right or true.',
      signAction:
          'Make "G" handshapes with both hands (index and thumb out). Drop the right hand on top of the left hand.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631793/CORRECT_0_qr7cwn.mov',
    ),
    DictionaryEntry(
      id: 18,
      label: 'SLOW',
      description: 'Moving or operating at a low speed.',
      signAction:
          'Pull the right hand slowly up the back of the left forearm, starting from the wrist.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632291/SLOW_0_xzvpxc.mov',
    ),
    DictionaryEntry(
      id: 19,
      label: 'FAST',
      description: 'Moving or operating at a high speed.',
      signAction:
          'Make "L" shapes with both hands, index fingers pointing forward. Quickly pull them back into "S" fists.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632105/FAST_0_pu9r0u.mov',
    ),
    DictionaryEntry(
      id: 20,
      label: 'ONE',
      description: 'The number 1.',
      signAction: 'Hold up the index finger, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632273/ONE_0_thzmtl.mov',
    ),
    DictionaryEntry(
      id: 21,
      label: 'TWO',
      description: 'The number 2.',
      signAction: 'Hold up the index and middle fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632291/SLOW_0_xzvpxc.mov',
    ),
    DictionaryEntry(
      id: 22,
      label: 'THREE',
      description: 'The number 3.',
      signAction:
          'Hold up the thumb, index, and middle fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632303/THREE_0_xzdo0k.mov',
    ),
    DictionaryEntry(
      id: 23,
      label: 'FOUR',
      description: 'The number 4.',
      signAction: 'Hold up four fingers (thumb tucked in), palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632175/FOUR_0_te1qhm.mov',
    ),
    DictionaryEntry(
      id: 24,
      label: 'FIVE',
      description: 'The number 5.',
      signAction: 'Hold up all five fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632113/FIVE_0_fmuikl.mov',
    ),
    DictionaryEntry(
      id: 25,
      label: 'SIX',
      description: 'The number 6.',
      signAction:
          'Touch the thumb to the pinky finger, holding the other three fingers up.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632290/SIX_0_ekjejk.mov',
    ),
    DictionaryEntry(
      id: 26,
      label: 'SEVEN',
      description: 'The number 7.',
      signAction: 'Touch the thumb to the ring finger.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632287/SEVEN_0_japlfj.mov',
    ),
    DictionaryEntry(
      id: 27,
      label: 'EIGHT',
      description: 'The number 8.',
      signAction: 'Touch the thumb to the middle finger.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632104/EIGHT_0_qcfzkq.mov',
    ),
    DictionaryEntry(
      id: 28,
      label: 'NINE',
      description: 'The number 9.',
      signAction: 'Touch the thumb to the index finger.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632266/NINE_0_ftiz4t.mov',
    ),
    DictionaryEntry(
      id: 29,
      label: 'TEN',
      description: 'The number 10.',
      signAction:
          'Make a fist with the thumb up (A-handshape) and shake it side to side.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632301/TEN_0_ls13qf.mov',
    ),
    DictionaryEntry(
      id: 30,
      label: 'JANUARY',
      description: 'The first month of the year.',
      signAction:
          'Form the letter "J" with your pinky and trace a J in the air.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632242/JANUARY_0_pkxjdx.mov',
    ),
    DictionaryEntry(
      id: 31,
      label: 'FEBRUARY',
      description: 'The second month of the year.',
      signAction:
          'Form the letter "F" (thumb and index circle) and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632108/FEBRUARY_0_lnsbdm.mov',
    ),
    DictionaryEntry(
      id: 32,
      label: 'MARCH',
      description: 'The third month of the year.',
      signAction: 'Form the letters M-A-R-C-H fingerspelled rapidly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632254/MARCH_0_jhcupq.mov',
    ),
    DictionaryEntry(
      id: 33,
      label: 'APRIL',
      description: 'The fourth month of the year.',
      signAction:
          'Form the letter "A" followed by "P", then circle rapidly or spell A-P-R-I-L.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631220/APRIL_0_t7jl8m.mov',
    ),
    DictionaryEntry(
      id: 34,
      label: 'MAY',
      description: 'The fifth month of the year.',
      signAction: 'Fingerspell M-A-Y.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632257/MAY_0_xgygm9.mov',
    ),
    DictionaryEntry(
      id: 35,
      label: 'JUNE',
      description: 'The sixth month of the year.',
      signAction:
          'Fingerspell J-U-N-E or using the "J" handshape, trace a J then shake.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632246/JUNE_0_u2wxxp.mov',
    ),
    DictionaryEntry(
      id: 36,
      label: 'JULY',
      description: 'The seventh month of the year.',
      signAction: 'Fingerspell J-U-L-Y.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632245/JULY_0_hsimui.mov',
    ),
    DictionaryEntry(
      id: 37,
      label: 'AUGUST',
      description: 'The eighth month of the year.',
      signAction: 'Fingerspell A-U-G.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631272/AUGUST_0_gjnpxb.mov',
    ),
    DictionaryEntry(
      id: 38,
      label: 'SEPTEMBER',
      description: 'The ninth month of the year.',
      signAction: 'Form the letter "S" (fist) and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632286/SEPTEMBER_0_fzdt4v.mov',
    ),
    DictionaryEntry(
      id: 39,
      label: 'OCTOBER',
      description: 'The tenth month of the year.',
      signAction: 'Form the letter "O" and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632272/OCTOBER_0_y2tk29.mov',
    ),
    DictionaryEntry(
      id: 40,
      label: 'NOVEMBER',
      description: 'The eleventh month of the year.',
      signAction:
          'Form the letter "N" (thumb between middle and ring fingers) and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632271/NOVEMBER_0_kxfhfd.mov',
    ),
    DictionaryEntry(
      id: 41,
      label: 'DECEMBER',
      description: 'The twelfth month of the year.',
      signAction:
          'Form the letter "D" (index up, others circling) and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632097/DECEMBER_0_rx5htc.mov',
    ),
    DictionaryEntry(
      id: 42,
      label: 'MONDAY',
      description: 'The first day of the week.',
      signAction:
          'Form the letter "M" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632262/MONDAY_0_pzcrr1.mov',
    ),
    DictionaryEntry(
      id: 43,
      label: 'TUESDAY',
      description: 'The second day of the week.',
      signAction:
          'Form the letter "T" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632309/TUESDAY_0_jervak.mov',
    ),
    DictionaryEntry(
      id: 44,
      label: 'WEDNESDAY',
      description: 'The third day of the week.',
      signAction:
          'Form the letter "W" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632317/WEDNESDAY_0_lbtim0.mov',
    ),
    DictionaryEntry(
      id: 45,
      label: 'THURSDAY',
      description: 'The fourth day of the week.',
      signAction:
          'Form the letter "H" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632305/THURSDAY_0_ikgb2m.mov',
    ),
    DictionaryEntry(
      id: 46,
      label: 'FRIDAY',
      description: 'The fifth day of the week.',
      signAction:
          'Form the letter "F" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632210/FRIDAY_0_l4ctd3.mov',
    ),
    DictionaryEntry(
      id: 47,
      label: 'SATURDAY',
      description: 'The sixth day of the week.',
      signAction:
          'Form the letter "S" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632283/SATURDAY_0_n96mwu.mov',
    ),
    DictionaryEntry(
      id: 48,
      label: 'SUNDAY',
      description: 'The seventh day of the week.',
      signAction:
          'Hold both hands up in an open "5" shape and move them in opposite circles (mimicking a conductor).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632297/SUNDAY_0_fgah1m.mov',
    ),
    DictionaryEntry(
      id: 49,
      label: 'TODAY',
      description: 'The present day.',
      signAction:
          'Make "Y" handshapes with both hands and bounce them down twice in front of the body.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632306/TODAY_0_uemuyr.mov',
    ),
    DictionaryEntry(
      id: 50,
      label: 'TOMORROW',
      description: 'The day after the present day.',
      signAction:
          'Make an "A" handshape with the thumb near the cheek, then twist the hand forward.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632308/TOMORROW_0_ciseme.mov',
    ),
    DictionaryEntry(
      id: 51,
      label: 'YESTERDAY',
      description: 'The day before the present day.',
      signAction:
          'Make an "A" or "Y" handshape, touch the thumb to the chin, then move it back to touch near the ear.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632328/YESTERDAY_0_wfxmxd.mov',
    ),
    DictionaryEntry(
      id: 52,
      label: 'FATHER',
      description: 'A male parent.',
      signAction:
          'Spread the fingers of the right hand and tap the thumb against the forehead.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632107/FATHER_0_hw04lk.mov',
    ),
    DictionaryEntry(
      id: 53,
      label: 'MOTHER',
      description: 'A female parent.',
      signAction:
          'Spread the fingers of the right hand and tap the thumb against the chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632263/MOTHER_0_wljybe.mov',
    ),
    DictionaryEntry(
      id: 54,
      label: 'SON',
      description: 'A male child.',
      signAction:
          'Perform the sign for "Male" (cap grasp at forehead) then transition to the sign for "Baby" (cradling arms).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632293/SON_0_hbbgj6.mov',
    ),
    DictionaryEntry(
      id: 55,
      label: 'DAUGHTER',
      description: 'A female child.',
      signAction:
          'Perform the sign for "Female" (thumb traces jaw) then transition to the sign for "Baby" (cradling arms).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632032/DAUGHTER_0_zrd96c.mov',
    ),
    DictionaryEntry(
      id: 56,
      label: 'GRANDFATHER',
      description: 'The father of one’s father or mother.',
      signAction:
          'Touch the thumb of an open "5" hand to the forehead and bounce the hand forward in two small arcs.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632228/GRANDFATHER_0_sytlai.mov',
    ),
    DictionaryEntry(
      id: 57,
      label: 'GRANDMOTHER',
      description: 'The mother of one’s father or mother.',
      signAction:
          'Touch the thumb of an open "5" hand to the chin and bounce the hand forward in two small arcs.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632230/GRANDMOTHER_0_iiqizu.mov',
    ),
    DictionaryEntry(
      id: 58,
      label: 'UNCLE',
      description:
          'The brother of one’s father or mother, or the husband of one’s aunt.',
      signAction:
          'Form the letter "U" with the right hand and twist it slightly near the side of the forehead.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632312/UNCLE_0_cmoxkt.mov',
    ),
    DictionaryEntry(
      id: 59,
      label: 'AUNTIE',
      description:
          'The sister of one’s father or mother, or the wife of one’s uncle.',
      signAction:
          'Form the letter "A" with the right hand and twist it slightly near the side of the chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631354/AUNTIE_0_wvcsni.mov',
    ),
    DictionaryEntry(
      id: 60,
      label: 'COUSIN',
      description: 'A child of one’s aunt or uncle.',
      signAction:
          'Form the letter "C" with the right hand and shake it gently by the side of the head.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631898/COUSIN_0_p7blg8.mov',
    ),
    DictionaryEntry(
      id: 61,
      label: 'PARENTS',
      description: 'A father and a mother.',
      signAction:
          'Perform the sign for "Mother" (thumb on chin) then "Father" (thumb on forehead) or vice versa.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632277/PARENTS_0_iolevw.mov',
    ),
    DictionaryEntry(
      id: 62,
      label: 'BOY',
      description: 'A male child or young man.',
      signAction:
          'Bring the hand to the forehead as if grabbing the brim of a baseball cap.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631763/BOY_0_d40joa.mov',
    ),
    DictionaryEntry(
      id: 63,
      label: 'GIRL',
      description: 'A female child or young woman.',
      signAction:
          'Trace the thumb of an "A" handshape along the jawline from ear to chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632211/GIRL_0_cc3mdg.mov',
    ),
    DictionaryEntry(
      id: 64,
      label: 'MAN',
      description: 'An adult male human being.',
      signAction:
          'Perform the sign for "Boy" at the forehead and then bring the hand down to the chest.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632253/MAN_0_dhpvlm.mov',
    ),
    DictionaryEntry(
      id: 65,
      label: 'WOMAN',
      description: 'An adult female human being.',
      signAction:
          'Perform the sign for "Girl" at the jawline and then bring the hand down to the chest.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632322/WOMAN_0_m7srwo.mov',
    ),
    DictionaryEntry(
      id: 66,
      label: 'DEAF',
      description: 'Partially or wholly lacking a sense of hearing.',
      signAction:
          'Touch the index finger to the ear, then move it to touch the mouth (or vice versa).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632094/DEAF_0_mzlmwq.mov',
    ),
    DictionaryEntry(
      id: 67,
      label: 'HARD OF HEARING',
      description: 'Having some difficulty hearing, but not completely deaf.',
      signAction: 'Make an "H" handshape and tap it twice in the air.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632234/HARD_OF_HEARING_0_wgvooh.mov',
    ),
    DictionaryEntry(
      id: 68,
      label: 'WEELCHAIR PERSON',
      description: 'A person who uses a wheelchair for mobility.',
      signAction:
          'Move both index fingers in forward circles at hip level (mimicking wheels) then add the "Person" marker (hands moving down body).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761640508/WEELCHAIR_PERSON_0_dhiqox.mov',
    ),
    DictionaryEntry(
      id: 69,
      label: 'BLIND',
      description: 'Lacking the sense of sight.',
      signAction:
          'Place two bent fingers pointing towards the eyes, then pull them away.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631760/BLIND_0_zbnnbb.mov',
    ),
    DictionaryEntry(
      id: 70,
      label: 'DEAF BLIND',
      description: 'Having both hearing and visual impairments.',
      signAction:
          'Perform the sign for "Deaf" (ear to mouth) followed immediately by the sign for "Blind" (fingers near eyes).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632096/DEAF_BLIND_0_lnoqf4.mov',
    ),
    DictionaryEntry(
      id: 71,
      label: 'MARRIED',
      description: 'Joined in marriage.',
      signAction:
          'Clasp both hands together, right hand on top of left, mimicking holding hands.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632256/MARRIED_0_l8lk8i.mov',
    ),
    DictionaryEntry(
      id: 72,
      label: 'BLUE',
      description: 'A primary color, the color of the clear sky.',
      signAction:
          'Form the letter "B" with the right hand and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631762/BLUE_0_dbkezd.mov',
    ),
    DictionaryEntry(
      id: 73,
      label: 'GREEN',
      description: 'A primary color, the color of growing grass or leaves.',
      signAction:
          'Form the letter "G" with the right hand and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632233/GREEN_0_u3kygt.mov',
    ),
    DictionaryEntry(
      id: 74,
      label: 'RED',
      description: 'A primary color, the color of blood or a ripe apple.',
      signAction:
          'Place the index finger on the lips and pull it downward past the chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632279/RED_0_quufbi.mov',
    ),
    DictionaryEntry(
      id: 75,
      label: 'BROWN',
      description: 'A dark color, the color of soil or wood.',
      signAction: 'Form the letter "B" and slide it down the side of the face.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631766/BROWN_0_lpt0ps.mov',
    ),
    DictionaryEntry(
      id: 76,
      label: 'BLACK',
      description: 'The darkest color, the absence of visible light.',
      signAction: 'Draw the index finger across the forehead horizontally.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631758/BLACK_0_jxyfok.mov',
    ),
    DictionaryEntry(
      id: 77,
      label: 'WHITE',
      description: 'The lightest color, the presence of all colors of light.',
      signAction:
          'Place the hand on the chest, fingers spread, and pull it outward closing the fingers (as if pulling a white shirt).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632320/WHITE_0_yjtrx1.mov',
    ),
    DictionaryEntry(
      id: 78,
      label: 'YELLOW',
      description: 'A primary color, the color of ripe lemons or the sun.',
      signAction: 'Form the letter "Y" with the right hand and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632325/YELLOW_0_b7peu9.mov',
    ),
    DictionaryEntry(
      id: 79,
      label: 'ORANGE',
      description: 'A secondary color, a mix of red and yellow.',
      signAction:
          ' Squeeze the hand into a fist repeatedly near the chin (like squeezing an orange).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632275/ORANGE_0_v6j1so.mov',
    ),
    DictionaryEntry(
      id: 80,
      label: 'GRAY',
      description: 'An intermediate color between black and white.',
      signAction:
          'Spread fingers of both hands and pass them through each other back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632231/GRAY_0_vhxvvl.mov',
    ),
    DictionaryEntry(
      id: 81,
      label: 'PINK',
      description: 'A light, pale red color.',
      signAction:
          'Form the letter "P" (or K) with the right hand and stroke the lips downward.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632278/PINK_0_rhtia7.mov',
    ),
    DictionaryEntry(
      id: 82,
      label: 'VIOLET',
      description:
          'A color at the short-wavelength end of the visible spectrum, next to blue.',
      signAction: 'Form the letter "V" and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632315/VIOLET_0_kbmy8y.mov',
    ),
    DictionaryEntry(
      id: 83,
      label: 'LIGHT',
      description: 'A low density of color, or the opposite of darkness.',
      signAction:
          'Raise both hands up and open the fingers wide, as if a light is shining.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632250/LIGHT_0_jqhugt.mov',
    ),
    DictionaryEntry(
      id: 84,
      label: 'DARK',
      description: 'A high density of color, or the opposite of light.',
      signAction: 'Cross both open hands over the face, blocking the view.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631917/DARK_0_wbccv5.mov',
    ),
    DictionaryEntry(
      id: 85,
      label: 'BREAD',
      description: 'A staple food made from flour, water, and yeast.',
      signAction:
          'Hold left arm horizontally. With right hand fingertips, make slicing motions down the back of the left hand.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631764/BREAD_0_yfnasu.mov',
    ),
    DictionaryEntry(
      id: 86,
      label: 'EGG',
      description: 'An oval object laid by a female bird, used as food.',
      signAction:
          'Tap the index and middle fingers of the right hand ("H" shape) against the left hand, then break them apart.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632102/EGG_0_sciape.mov',
    ),
    DictionaryEntry(
      id: 87,
      label: 'FISH',
      description:
          'A cold-blooded animal with fins and gills that lives in water, used as food.',
      signAction:
          'Extend the right hand vertically, fingers together, and wiggle the hand while moving it forward like a swimming fish.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632111/FISH_0_uwsbpw.mov',
    ),
    DictionaryEntry(
      id: 88,
      label: 'MEAT',
      description: 'The flesh of an animal used as food.',
      signAction:
          'Grab the fleshy part of the left hand (between thumb and index) with the right thumb and index finger.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632259/MEAT_0_oorpwd.mov',
    ),
    DictionaryEntry(
      id: 89,
      label: 'CHICKEN',
      description: 'A common type of domesticated bird, used as food.',
      signAction:
          'Tap the thumb and index finger together near the mouth (mimicking a beak).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631767/CHICKEN_0_s01uva.mov',
    ),
    DictionaryEntry(
      id: 90,
      label: 'SPAGHETTI',
      description:
          'A type of pasta in the form of long, thin, solid cylinders.',
      signAction:
          'Using "I" (pinky) fingers of both hands, draw squiggly lines in the air moving away from each other.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632294/SPAGHETTI_0_wicuxb.mov',
    ),
    DictionaryEntry(
      id: 91,
      label: 'RICE',
      description: 'A staple grain from an Asian grass, widely consumed.',
      signAction:
          'Cup the right hand and bring it to the mouth repeatedly, mimicking eating rice with hands.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632281/RICE_0_wbtsaf.mov',
    ),
    DictionaryEntry(
      id: 92,
      label: 'LONGANISA',
      description: 'A common Filipino pork sausage.',
      signAction:
          'Use index fingers and thumbs to mime the shape of small links of sausages in a chain.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632251/LONGANISA_0_ejeuqb.mov',
    ),
    DictionaryEntry(
      id: 93,
      label: 'SHRIMP',
      description: 'A small edible crustacean.',
      signAction:
          'Wiggle the index finger (crooked) while moving the hand forward.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632288/SHRIMP_0_ll9evw.mov',
    ),
    DictionaryEntry(
      id: 94,
      label: 'CRAB',
      description: 'A marine crustacean with ten legs, used as food.',
      signAction: 'Use both hands to mimic pincers opening and closing.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631899/CRAB_0_y1kkoo.mov',
    ),
    DictionaryEntry(
      id: 95,
      label: 'HOT',
      description: 'Having a high temperature or spicy flavor.',
      signAction:
          'Place a "claw" shaped hand near the mouth and twist it outward quickly.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632238/HOT_0_p9nbz1.mov',
    ),
    DictionaryEntry(
      id: 96,
      label: 'COLD',
      description: 'Having a low temperature.',
      signAction: 'Clench fists and shiver the arms and body.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631774/COLD_0_poprtq.mov',
    ),
    DictionaryEntry(
      id: 97,
      label: 'JUICE',
      description:
          'The liquid naturally contained in fruit or vegetable tissue.',
      signAction: 'Form the letter "J" near the mouth.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632243/JUICE_0_o76khv.mov',
    ),
    DictionaryEntry(
      id: 98,
      label: 'MILK',
      description: 'A white liquid produced by the mammary glands of mammals.',
      signAction:
          'Squeeze the right hand into a fist repeatedly (mimicking milking a cow).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632260/MILK_0_fkuw9n.mov',
    ),
    DictionaryEntry(
      id: 99,
      label: 'COFFEE',
      description: 'A beverage made from roasted and ground coffee beans.',
      signAction:
          'Make fists with both hands. Circle the top fist over the bottom fist (mimicking a grinder).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631773/COFFEE_0_xwlcqy.mov',
    ),
    DictionaryEntry(
      id: 100,
      label: 'TEA',
      description:
          'An aromatic beverage commonly prepared by pouring hot water over cured leaves.',
      signAction:
          'Use the thumb and index finger to mimic dipping a tea bag into a cup (made by the other hand).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632299/TEA_0_uknenz.mov',
    ),
    DictionaryEntry(
      id: 101,
      label: 'BEER',
      description: 'An alcoholic beverage made from fermented grain.',
      signAction: 'Rub the side of the "B" handshape against the cheek.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631373/BEER_0_wnlsuh.mov',
    ),
    DictionaryEntry(
      id: 102,
      label: 'WINE',
      description:
          'An alcoholic beverage typically made from fermented grapes.',
      signAction: 'Rub the letter "W" against the cheek in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632321/WINE_0_vyrmmg.mov',
    ),
    DictionaryEntry(
      id: 103,
      label: 'SUGAR',
      description: 'A sweet-tasting, crystalline carbohydrate.',
      signAction:
          'Brush the fingers of the right hand downward against the chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632296/SUGAR_0_scqvbq.mov',
    ),
    DictionaryEntry(
      id: 104,
      label: 'NO SUGAR',
      description: 'An instruction to omit or avoid sugar.',
      signAction:
          'Sign "No" (fingers snapping shut) followed by "Sugar" (fingers brushing chin).',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632269/NO_SUGAR_0_eh0b2w.mov',
    ),
  ];
  // A method to get all dictionary entries
  List<DictionaryEntry> getAllEntries() {
    return _entries;
  }

  List<DictionaryEntry> searchEntries(String query) {
    if (query.isEmpty) {
      return _entries;
    }
    return _entries
        .where(
          (entry) => entry.label.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
