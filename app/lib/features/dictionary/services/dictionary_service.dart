import '../models/dictionary_entry.dart';

class DictionaryService {
  static const String _cloudinaryBaseUrl =
      'https://res.cloudinary.com/YOUR_CLOUD_NAME/video/upload/';

  String cloudName = 'dhfbeubal';

  static final List<DictionaryEntry> _entries = [
    DictionaryEntry(
      id: 0,
      label: 'MAGANDANG UMAGA',
      description: 'A common greeting used in the morning.',
      signAction:
          'Place fingers of right hand on chin, move hand down to the open palm of the left hand ("Good"). Then, place right hand in the crook of the left elbow and raise the right forearm up ("Morning").',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408401/GOOD_MORNING_0_bo4ont.mov',
    ),
    DictionaryEntry(
      id: 1,
      label: 'MAGANDANG HAPON',
      description: 'A common greeting used in the afternoon.',
      signAction:
          'Perform the sign for "Good". Then, with the right arm extended forward, open palm facing down, lower the arm slightly to represent the sun going down.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408400/GOOD_AFTERNOON_0_b3on0t.mov',
    ),
    DictionaryEntry(
      id: 2,
      label: 'MAGANDANG GABI',
      description: 'A common greeting used in the evening.',
      signAction:
          'Perform the sign for "Good". Then, cross the right wrist over the left wrist, hands curving down, mimicking the sun setting over the horizon.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408400/GOOD_EVENING_0_u6smhx.mov',
    ),
    DictionaryEntry(
      id: 3,
      label: 'KUMUSTA',
      description: 'A basic greeting.',
      signAction:
          'Bring the right hand to the forehead with palm facing out, similar to a salute, and move it outward away from the head.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408402/HELLO_0_gvxk6c.mov',
    ),
    DictionaryEntry(
      id: 4,
      label: 'KUMUSTA KA',
      description: 'A common phrase used to ask about a person’s well-being.',
      signAction:
          'Place both curved hands with knuckles touching the chest, then twist them outward so palms face up. Point to the other person at the end.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408403/HOW_ARE_YOU_0_k9vkqp.mov',
    ),
    DictionaryEntry(
      id: 5,
      label: 'AYOS LANG AKO',
      description: 'A common response indicating good health or condition.',
      signAction:
          'Touch the thumb of your open "5-hand" to your chest and tap it twice repeatedly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408403/IM_FINE_0_rcvcuo.mov',
    ),
    DictionaryEntry(
      id: 6,
      label: 'IKINAGAGALAK KONG MAKILALA KA',
      description: 'A polite phrase used upon meeting someone.',
      signAction:
          'Slide the right palm over the left palm ("Nice"). Then bring both index fingers together so they meet in the middle ("Meet"). Point to the person ("You").',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408407/NICE_TO_MEET_YOU_0_dxyp32.mov',
    ),
    DictionaryEntry(
      id: 7,
      label: 'SALAMAT',
      description: 'An expression of gratitude.',
      signAction:
          'Touch the fingertips of your open right hand to your chin, then move the hand outward towards the other person.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408414/THANK_YOU_0_kgz4b6.mov',
    ),
    DictionaryEntry(
      id: 8,
      label: 'WALANG ANUMAN',
      description: 'A polite response to "Thank you."',
      signAction:
          'With the right open hand palm up, swoop the hand inward toward your waist and then outward towards the person.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408418/YOURE_WELCOME_0_z2o4ig.mov',
    ),
    DictionaryEntry(
      id: 9,
      label: 'MAGKITA TAYO BUKAS',
      description: 'A common farewell used when planning to meet the next day.',
      signAction:
          'Tap the "V" handshape near the eye ("See"). Point to the person ("You"). Make a thumbs-up shape near the cheek and move it forward ("Tomorrow").',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408411/SEE_YOU_TOMORROW_0_wgyage.mov',
    ),
    DictionaryEntry(
      id: 10,
      label: 'NAIINTINDIHAN',
      description: 'To grasp the meaning of information.',
      signAction:
          'Place a closed fist near the side of your forehead, then flick the index finger upward, like a lightbulb turning on.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408415/UNDERSTAND_0_me1szd.mov',
    ),
    DictionaryEntry(
      id: 11,
      label: 'HINDI NAIINTINDIHAN',
      description: 'To not grasp the meaning of information.',
      signAction:
          'Perform the sign for "Understand", but shake your head side-to-side (negation) while doing it.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408397/DON_T_UNDERSTAND_0_gfktnw.mov',
    ),
    DictionaryEntry(
      id: 12,
      label: 'ALAM',
      description: 'To be aware of something.',
      signAction:
          'Tap the fingertips of your bent right hand against the side of your forehead.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408404/KNOW_0_nqbvos.mov',
    ),
    DictionaryEntry(
      id: 13,
      label: 'HINDI ALAM',
      description: 'To not be aware of something.',
      signAction:
          'Touch the forehead with fingertips, then turn the hand outward vigorously while shaking the head.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408397/DON_T_UNDERSTAND_0_gfktnw.mov',
    ),
    DictionaryEntry(
      id: 14,
      label: 'HINDI',
      description:
          'An answer or statement that expresses disagreement or denial.',
      signAction:
          'Tap the index and middle fingers together against the thumb, mimicking a mouth closing.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408408/NO_0_zpybiu.mov',
    ),
    DictionaryEntry(
      id: 15,
      label: 'OO',
      description:
          'An answer or statement that expresses agreement or affirmation.',
      signAction:
          'Make a fist (S-handshape) and bob it up and down like a head nodding.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408418/YES_0_ykg9ie.mov',
    ),
    DictionaryEntry(
      id: 16,
      label: 'MALI',
      description: 'Incorrect or not true.',
      signAction:
          'Make a "Y" handshape (thumb and pinky out) and tap the chin with the back of the hand.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408417/WRONG_0_telk7b.mov',
    ),
    DictionaryEntry(
      id: 17,
      label: 'TAMA',
      description: 'Right or true.',
      signAction:
          'Make "G" handshapes with both hands (index and thumb out). Drop the right hand on top of the left hand.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408361/CORRECT_0_awzmwa.mov',
    ),
    DictionaryEntry(
      id: 18,
      label: 'MABAGAL',
      description: 'Moving or operating at a low speed.',
      signAction:
          'Pull the right hand slowly up the back of the left forearm, starting from the wrist.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408412/SLOW_0_gues2b.mov',
    ),
    DictionaryEntry(
      id: 19,
      label: 'MABILIS',
      description: 'Moving or operating at a high speed.',
      signAction:
          'Make "L" shapes with both hands, index fingers pointing forward. Quickly pull them back into "S" fists.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408398/FAST_0_sichzp.mov',
    ),
    DictionaryEntry(
      id: 20,
      label: 'ISA',
      description: 'The number 1.',
      signAction: 'Hold up the index finger, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408409/ONE_0_yq82ky.mov',
    ),
    DictionaryEntry(
      id: 21,
      label: 'DALAWA',
      description: 'The number 2.',
      signAction: 'Hold up the index and middle fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408415/TWO_0_coeyci.mov',
    ),
    DictionaryEntry(
      id: 22,
      label: 'TATLO',
      description: 'The number 3.',
      signAction:
          'Hold up the thumb, index, and middle fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408414/THREE_0_ru2nvx.mov',
    ),
    DictionaryEntry(
      id: 23,
      label: 'APAT',
      description: 'The number 4.',
      signAction: 'Hold up four fingers (thumb tucked in), palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408399/FOUR_0_hwxhd0.mov',
    ),
    DictionaryEntry(
      id: 24,
      label: 'LIMA',
      description: 'The number 5.',
      signAction: 'Hold up all five fingers, palm facing out.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408399/FIVE_0_cse97z.mov',
    ),
    DictionaryEntry(
      id: 25,
      label: 'ANIM',
      description: 'The number 6.',
      signAction:
          'Touch the thumb to the pinky finger, holding the other three fingers up.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408411/SIX_0_zyhosu.mov',
    ),
    DictionaryEntry(
      id: 26,
      label: 'PITO',
      description: 'The number 7.',
      signAction: 'Touch the thumb to the ring finger.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408411/SEVEN_0_almnul.mov',
    ),
    DictionaryEntry(
      id: 27,
      label: 'WALO',
      description: 'The number 8.',
      signAction: 'Touch the thumb to the middle finger.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408397/EIGHT_0_ublrim.mov',
    ),
    DictionaryEntry(
      id: 28,
      label: 'SIYAM',
      description: 'The number 9.',
      signAction: 'Touch the thumb to the index finger.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408407/NINE_0_bxbfz1.mov',
    ),
    DictionaryEntry(
      id: 29,
      label: 'SAMPU',
      description: 'The number 10.',
      signAction:
          'Make a fist with the thumb up (A-handshape) and shake it side to side.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408413/TEN_0_rgacrj.mov',
    ),
    DictionaryEntry(
      id: 30,
      label: 'ENERO',
      description: 'The first month of the year.',
      signAction:
          'Form the letter "J" with your pinky and trace a J in the air.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408404/JANUARY_0_lksvue.mov',
    ),
    DictionaryEntry(
      id: 31,
      label: 'PEBRERO',
      description: 'The second month of the year.',
      signAction:
          'Form the letter "F" (thumb and index circle) and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408398/FEBRUARY_0_grht2j.mov',
    ),
    DictionaryEntry(
      id: 32,
      label: 'MARSO',
      description: 'The third month of the year.',
      signAction: 'Form the letters M-A-R-C-H fingerspelled rapidly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408405/MARCH_0_wzpobn.mov',
    ),
    DictionaryEntry(
      id: 33,
      label: 'ABRIL',
      description: 'The fourth month of the year.',
      signAction:
          'Form the letter "A" followed by "P", then circle rapidly or spell A-P-R-I-L.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408359/APRIL_0_pomp5k.mov',
    ),
    DictionaryEntry(
      id: 34,
      label: 'MAYO',
      description: 'The fifth month of the year.',
      signAction: 'Fingerspell M-A-Y.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408406/MAY_0_ctopyw.mov',
    ),
    DictionaryEntry(
      id: 35,
      label: 'HUNYO',
      description: 'The sixth month of the year.',
      signAction:
          'Fingerspell J-U-N-E or using the "J" handshape, trace a J then shake.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408404/JUNE_0_zlpmvf.mov',
    ),
    DictionaryEntry(
      id: 36,
      label: 'HULYO',
      description: 'The seventh month of the year.',
      signAction: 'Fingerspell J-U-L-Y.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408404/JULY_0_ipxczz.mov',
    ),
    DictionaryEntry(
      id: 37,
      label: 'AGOSTO',
      description: 'The eighth month of the year.',
      signAction: 'Fingerspell A-U-G.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408359/AUGUST_0_sumkel.mov',
    ),
    DictionaryEntry(
      id: 38,
      label: 'SETYEMBRE',
      description: 'The ninth month of the year.',
      signAction: 'Form the letter "S" (fist) and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408411/SEPTEMBER_0_ebzxrn.mov',
    ),
    DictionaryEntry(
      id: 39,
      label: 'OKTUBRE',
      description: 'The tenth month of the year.',
      signAction: 'Form the letter "O" and shake it slightly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408408/OCTOBER_0_aqefol.mov',
    ),
    DictionaryEntry(
      id: 40,
      label: 'NOBYEMBRE',
      description: 'The eleventh month of the year.',
      signAction:
          'Form the letter "N" (thumb between middle and ring fingers) and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408408/NOVEMBER_0_jpk4fe.mov',
    ),
    DictionaryEntry(
      id: 41,
      label: 'DISYEMBRE',
      description: 'The twelfth month of the year.',
      signAction:
          'Form the letter "D" (index up, others circling) and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408398/DECEMBER_0_pg7uck.mov',
    ),
    DictionaryEntry(
      id: 42,
      label: 'LUNES',
      description: 'The first day of the week.',
      signAction:
          'Form the letter "M" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408407/MONDAY_0_zjfoal.mov',
    ),
    DictionaryEntry(
      id: 43,
      label: 'MARTES',
      description: 'The second day of the week.',
      signAction:
          'Form the letter "T" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408415/TUESDAY_0_h1l7cv.mov',
    ),
    DictionaryEntry(
      id: 44,
      label: 'MIYERKULES',
      description: 'The third day of the week.',
      signAction:
          'Form the letter "W" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408416/WEDNESDAY_0_jfpcnv.mov',
    ),
    DictionaryEntry(
      id: 45,
      label: 'HUWEBES',
      description: 'The fourth day of the week.',
      signAction:
          'Form the letter "H" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408414/THURSDAY_0_b6c7b3.mov',
    ),
    DictionaryEntry(
      id: 46,
      label: 'BIYERNES',
      description: 'The fifth day of the week.',
      signAction:
          'Form the letter "F" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408400/FRIDAY_0_m1hoav.mov',
    ),
    DictionaryEntry(
      id: 47,
      label: 'SABADO',
      description: 'The sixth day of the week.',
      signAction:
          'Form the letter "S" with your hand and move it in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408410/SATURDAY_0_l4bphk.mov',
    ),
    DictionaryEntry(
      id: 48,
      label: 'LINGGO',
      description: 'The seventh day of the week.',
      signAction:
          'Hold both hands up in an open "5" shape and move them in opposite circles (mimicking a conductor).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408413/SUNDAY_0_tvmaag.mov',
    ),
    DictionaryEntry(
      id: 49,
      label: 'NGAYON',
      description: 'The present day.',
      signAction:
          'Make "Y" handshapes with both hands and bounce them down twice in front of the body.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408414/TODAY_0_xrdwyl.mov',
    ),
    DictionaryEntry(
      id: 50,
      label: 'BUKAS',
      description: 'The day after the present day.',
      signAction:
          'Make an "A" handshape with the thumb near the cheek, then twist the hand forward.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408414/TOMORROW_0_ezjxti.mov',
    ),
    DictionaryEntry(
      id: 51,
      label: 'KAHAPON',
      description: 'The day before the present day.',
      signAction:
          'Make an "A" or "Y" handshape, touch the thumb to the chin, then move it back to touch near the ear.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408417/YESTERDAY_0_yenm7w.mov',
    ),
    DictionaryEntry(
      id: 52,
      label: 'TATAY',
      description: 'A male parent.',
      signAction:
          'Spread the fingers of the right hand and tap the thumb against the forehead.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408398/FATHER_0_qtxvhb.mov',
    ),
    DictionaryEntry(
      id: 53,
      label: 'NANAY',
      description: 'A female parent.',
      signAction:
          'Spread the fingers of the right hand and tap the thumb against the chin.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408407/MOTHER_0_g8rvbd.mov',
    ),
    DictionaryEntry(
      id: 54,
      label: 'ANAK NA LALAKI',
      description: 'A male child.',
      signAction:
          'Perform the sign for "Male" (cap grasp at forehead) then transition to the sign for "Baby" (cradling arms).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408412/SON_0_fb4q4s.mov',
    ),
    DictionaryEntry(
      id: 55,
      label: 'ANAK NA BABAE',
      description: 'A female child.',
      signAction:
          'Perform the sign for "Female" (thumb traces jaw) then transition to the sign for "Baby" (cradling arms).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408384/DAUGHTER_0_muadpy.mov',
    ),
    DictionaryEntry(
      id: 56,
      label: 'LOLO',
      description: 'The father of one’s father or mother.',
      signAction:
          'Touch the thumb of an open "5" hand to the forehead and bounce the hand forward in two small arcs.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632228/GRANDFATHER_0_sytlai.mov',
    ),
    DictionaryEntry(
      id: 57,
      label: 'LOLA',
      description: 'The mother of one’s father or mother.',
      signAction:
          'Touch the thumb of an open "5" hand to the chin and bounce the hand forward in two small arcs.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632230/GRANDMOTHER_0_iiqizu.mov',
    ),
    DictionaryEntry(
      id: 58,
      label: 'TITO',
      description:
          'The brother of one’s father or mother, or the husband of one’s aunt.',
      signAction:
          'Form the letter "U" with the right hand and twist it slightly near the side of the forehead.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761632312/UNCLE_0_cmoxkt.mov',
    ),
    DictionaryEntry(
      id: 59,
      label: 'TITA',
      description:
          'The sister of one’s father or mother, or the wife of one’s uncle.',
      signAction:
          'Form the letter "A" with the right hand and twist it slightly near the side of the chin.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631354/AUNTIE_0_wvcsni.mov',
    ),
    DictionaryEntry(
      id: 60,
      label: 'PINSAN',
      description: 'A child of one’s aunt or uncle.',
      signAction:
          'Form the letter "C" with the right hand and shake it gently by the side of the head.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631898/COUSIN_0_p7blg8.mov',
    ),
    DictionaryEntry(
      id: 61,
      label: 'MAGULANG',
      description: 'A father and a mother.',
      signAction:
          'Perform the sign for "Mother" (thumb on chin) then "Father" (thumb on forehead) or vice versa.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408409/PARENTS_0_kk4m36.mov',
    ),
    DictionaryEntry(
      id: 62,
      label: 'BATANG LALAKI',
      description: 'A male child or young man.',
      signAction:
          'Bring the hand to the forehead as if grabbing the brim of a baseball cap.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408359/BOY_0_u5roak.mov',
    ),
    DictionaryEntry(
      id: 63,
      label: 'BATANG BABAE',
      description: 'A female child or young woman.',
      signAction:
          'Trace the thumb of an "A" handshape along the jawline from ear to chin.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408400/GIRL_0_nfbzhr.mov',
    ),
    DictionaryEntry(
      id: 64,
      label: 'LALAKI',
      description: 'An adult male human being.',
      signAction:
          'Perform the sign for "Boy" at the forehead and then bring the hand down to the chest.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408405/MAN_0_hucciq.mov',
    ),
    DictionaryEntry(
      id: 65,
      label: 'BABAE',
      description: 'An adult female human being.',
      signAction:
          'Perform the sign for "Girl" at the jawline and then bring the hand down to the chest.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408417/WOMAN_0_swde5c.mov',
    ),
    DictionaryEntry(
      id: 66,
      label: 'BINGI',
      description: 'Partially or wholly lacking a sense of hearing.',
      signAction:
          'Touch the index finger to the ear, then move it to touch the mouth (or vice versa).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408396/DEAF_0_l2prxf.mov',
    ),
    DictionaryEntry(
      id: 67,
      label: 'MAHINA ANG PANDINIG',
      description: 'Having some difficulty hearing, but not completely deaf.',
      signAction: 'Make an "H" handshape and tap it twice in the air.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408402/HARD_OF_HEARING_0_g07bxq.mov',
    ),
    DictionaryEntry(
      id: 68,
      label: 'TAONG NAKA-WHEELCHAIR',
      description: 'A person who uses a wheelchair for mobility.',
      signAction:
          'Move both index fingers in forward circles at hip level (mimicking wheels) then add the "Person" marker (hands moving down body).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408416/WEELCHAIR_PERSON_0_p3z3nn.mov',
    ),
    DictionaryEntry(
      id: 69,
      label: 'BULAG',
      description: 'Lacking the sense of sight.',
      signAction:
          'Place two bent fingers pointing towards the eyes, then pull them away.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408360/BLIND_0_zldvqu.mov',
    ),
    DictionaryEntry(
      id: 70,
      label: 'BINGI AT BULAG',
      description: 'Having both hearing and visual impairments.',
      signAction:
          'Perform the sign for "Deaf" (ear to mouth) followed immediately by the sign for "Blind" (fingers near eyes).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408397/DEAF_BLIND_0_ywt8ne.mov',
    ),
    DictionaryEntry(
      id: 71,
      label: 'KASAL',
      description: 'Joined in marriage.',
      signAction:
          'Clasp both hands together, right hand on top of left, mimicking holding hands.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408406/MARRIED_0_l2t9az.mov',
    ),
    DictionaryEntry(
      id: 72,
      label: 'ASUL',
      description: 'A primary color, the color of the clear sky.',
      signAction:
          'Form the letter "B" with the right hand and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408359/BLUE_0_lhahpy.mov',
    ),
    DictionaryEntry(
      id: 73,
      label: 'BERDE',
      description: 'A primary color, the color of growing grass or leaves.',
      signAction:
          'Form the letter "G" with the right hand and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408402/GREEN_0_lngckb.mov',
    ),
    DictionaryEntry(
      id: 74,
      label: 'PULA',
      description: 'A primary color, the color of blood or a ripe apple.',
      signAction:
          'Place the index finger on the lips and pull it downward past the chin.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408410/RED_0_vap24d.mov',
    ),
    DictionaryEntry(
      id: 75,
      label: 'KAYUMANGGI',
      description: 'A dark color, the color of soil or wood.',
      signAction: 'Form the letter "B" and slide it down the side of the face.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408360/BROWN_0_nx26oq.mov',
    ),
    DictionaryEntry(
      id: 76,
      label: 'ITIM',
      description: 'The darkest color, the absence of visible light.',
      signAction: 'Draw the index finger across the forehead horizontally.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408360/BLACK_0_jbglnn.mov',
    ),
    DictionaryEntry(
      id: 77,
      label: 'PUTI',
      description: 'The lightest color, the presence of all colors of light.',
      signAction:
          'Place the hand on the chest, fingers spread, and pull it outward closing the fingers (as if pulling a white shirt).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408416/WHITE_0_kr1t32.mov',
    ),
    DictionaryEntry(
      id: 78,
      label: 'DILAW',
      description: 'A primary color, the color of ripe lemons or the sun.',
      signAction: 'Form the letter "Y" with the right hand and shake it.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408417/YELLOW_0_iljzi2.mov',
    ),
    DictionaryEntry(
      id: 79,
      label: 'KAHEL',
      description: 'A secondary color, a mix of red and yellow.',
      signAction:
          ' Squeeze the hand into a fist repeatedly near the chin (like squeezing an orange).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408409/ORANGE_0_unwmtp.mov',
    ),
    DictionaryEntry(
      id: 80,
      label: 'KULAY ABO',
      description: 'An intermediate color between black and white.',
      signAction:
          'Spread fingers of both hands and pass them through each other back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408401/GRAY_0_qwf2jy.mov',
    ),
    DictionaryEntry(
      id: 81,
      label: 'KULAY ROSAS',
      description: 'A light, pale red color.',
      signAction:
          'Form the letter "P" (or K) with the right hand and stroke the lips downward.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408409/PINK_0_dmg5lj.mov',
    ),
    DictionaryEntry(
      id: 82,
      label: 'LILA',
      description:
          'A color at the short-wavelength end of the visible spectrum, next to blue.',
      signAction: 'Form the letter "V" and shake it back and forth.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408416/VIOLET_0_hiqnoy.mov',
    ),
    DictionaryEntry(
      id: 83,
      label: 'LIWANAG',
      description: 'A low density of color, or the opposite of darkness.',
      signAction:
          'Raise both hands up and open the fingers wide, as if a light is shining.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408405/LIGHT_0_cybtbu.mov',
    ),
    DictionaryEntry(
      id: 84,
      label: 'DILIM',
      description: 'A high density of color, or the opposite of light.',
      signAction: 'Cross both open hands over the face, blocking the view.',
      videoUrl:
          'https://res.cloudinary.com/dxau89gcg/video/upload/v1761631917/DARK_0_wbccv5.mov',
    ),
    DictionaryEntry(
      id: 85,
      label: 'TINAPAY',
      description: 'A staple food made from flour, water, and yeast.',
      signAction:
          'Hold left arm horizontally. With right hand fingertips, make slicing motions down the back of the left hand.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408360/BREAD_0_gyxvs5.mov',
    ),
    DictionaryEntry(
      id: 86,
      label: 'ITLOG',
      description: 'An oval object laid by a female bird, used as food.',
      signAction:
          'Tap the index and middle fingers of the right hand ("H" shape) against the left hand, then break them apart.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408397/EGG_0_f64u1c.mov',
    ),
    DictionaryEntry(
      id: 87,
      label: 'ISDA',
      description:
          'A cold-blooded animal with fins and gills that lives in water, used as food.',
      signAction:
          'Extend the right hand vertically, fingers together, and wiggle the hand while moving it forward like a swimming fish.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408399/FISH_0_z6qefe.mov',
    ),
    DictionaryEntry(
      id: 88,
      label: 'KARNE',
      description: 'The flesh of an animal used as food.',
      signAction:
          'Grab the fleshy part of the left hand (between thumb and index) with the right thumb and index finger.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408406/MEAT_0_mje3fr.mov',
    ),
    DictionaryEntry(
      id: 89,
      label: 'MANOK',
      description: 'A common type of domesticated bird, used as food.',
      signAction:
          'Tap the thumb and index finger together near the mouth (mimicking a beak).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408361/CHICKEN_0_m9rzpe.mov',
    ),
    DictionaryEntry(
      id: 90,
      label: 'ISPAGETI',
      description:
          'A type of pasta in the form of long, thin, solid cylinders.',
      signAction:
          'Using "I" (pinky) fingers of both hands, draw squiggly lines in the air moving away from each other.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408412/SPAGHETTI_0_oi2e5g.mov',
    ),
    DictionaryEntry(
      id: 91,
      label: 'KANIN',
      description: 'A staple grain from an Asian grass, widely consumed.',
      signAction:
          'Cup the right hand and bring it to the mouth repeatedly, mimicking eating rice with hands.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408410/RICE_0_la5wqm.mov',
    ),
    DictionaryEntry(
      id: 92,
      label: 'LONGGANISA',
      description: 'A common Filipino pork sausage.',
      signAction:
          'Use index fingers and thumbs to mime the shape of small links of sausages in a chain.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408405/LONGANISA_0_ltccjr.mov',
    ),
    DictionaryEntry(
      id: 93,
      label: 'HIPON',
      description: 'A small edible crustacean.',
      signAction:
          'Wiggle the index finger (crooked) while moving the hand forward.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408411/SHRIMP_0_lhaywm.mov',
    ),
    DictionaryEntry(
      id: 94,
      label: 'ALIMANGO',
      description: 'A marine crustacean with ten legs, used as food.',
      signAction: 'Use both hands to mimic pincers opening and closing.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408361/CRAB_0_afv16m.mov',
    ),
    DictionaryEntry(
      id: 95,
      label: 'MAINIT',
      description: 'Having a high temperature or spicy flavor.',
      signAction:
          'Place a "claw" shaped hand near the mouth and twist it outward quickly.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408403/HOT_0_wkkuwa.mov',
    ),
    DictionaryEntry(
      id: 96,
      label: 'MALAMIG',
      description: 'Having a low temperature.',
      signAction: 'Clench fists and shiver the arms and body.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408361/COLD_0_p9tbpt.mov',
    ),
    DictionaryEntry(
      id: 97,
      label: 'JUICE',
      description:
          'The liquid naturally contained in fruit or vegetable tissue.',
      signAction: 'Form the letter "J" near the mouth.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408404/JUICE_0_bjxsi5.mov',
    ),
    DictionaryEntry(
      id: 98,
      label: 'GATAS',
      description: 'A white liquid produced by the mammary glands of mammals.',
      signAction:
          'Squeeze the right hand into a fist repeatedly (mimicking milking a cow).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408406/MILK_0_wamqed.mov',
    ),
    DictionaryEntry(
      id: 99,
      label: 'KAPE',
      description: 'A beverage made from roasted and ground coffee beans.',
      signAction:
          'Make fists with both hands. Circle the top fist over the bottom fist (mimicking a grinder).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408360/COFFEE_0_xzkxge.mov',
    ),
    DictionaryEntry(
      id: 100,
      label: 'TSAA',
      description:
          'An aromatic beverage commonly prepared by pouring hot water over cured leaves.',
      signAction:
          'Use the thumb and index finger to mimic dipping a tea bag into a cup (made by the other hand).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408413/TEA_0_aegbmt.mov',
    ),
    DictionaryEntry(
      id: 101,
      label: 'BEER',
      description: 'An alcoholic beverage made from fermented grain.',
      signAction: 'Rub the side of the "B" handshape against the cheek.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408359/BEER_0_q9fa7n.mov',
    ),
    DictionaryEntry(
      id: 102,
      label: 'ALAK',
      description:
          'An alcoholic beverage typically made from fermented grapes.',
      signAction: 'Rub the letter "W" against the cheek in a small circle.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408416/WINE_0_q7bipb.mov',
    ),
    DictionaryEntry(
      id: 103,
      label: 'ASUKAL',
      description: 'A sweet-tasting, crystalline carbohydrate.',
      signAction:
          'Brush the fingers of the right hand downward against the chin.',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408412/SUGAR_0_tkuylr.mov',
    ),
    DictionaryEntry(
      id: 104,
      label: 'WALANG ASUKAL',
      description: 'An instruction to omit or avoid sugar.',
      signAction:
          'Sign "No" (fingers snapping shut) followed by "Sugar" (fingers brushing chin).',
      videoUrl:
          'https://res.cloudinary.com/dhfbeubal/video/upload/v1776408408/NO_SUGAR_0_wqlqeq.mov',
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
