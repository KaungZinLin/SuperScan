import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale("my", LocaleData.MY),
  MapLocale("zh", LocaleData.ZH),
  MapLocale("zh_Hant", LocaleData.ZH_HANT),
  MapLocale("vi", LocaleData.VI),
];

mixin LocaleData {
  // Home
  static const String title = 'title';
  static const String pages = 'pages';
  static const String scan = 'scan';
  static const String options_alert = 'options_alert';
  static const String options_message = 'options_message';

  // Universal
  static const String cancel = 'cancel';
  static const String close = 'close';
  static const String done = 'done';
  static const String unexpected_error = 'unexpected_error';
  static const String clipboard_copy = 'clipboard_copy';
  static const String share_tooltip = 'share_tooltip';
  static const String clipboard_tooltip = 'clipboard_tooltip';

  // Settings
  static const String settings = 'settings';
  static const String google_account_for_sync = 'google_account_for_sync';
  static const String not_signed_in = 'not_signed_in';
  static const String sign_in = 'sign_in';
  static const String sign_out = 'sign_out';
  static const String sign_out_question = 'sign_out_question';
  static const String sign_out_success = 'sign_out_success';
  static const String sign_out_failed = 'sign_out_failed';
  static const String get_on_dekstop = 'get_on_desktop';
  static const String ai_config = 'ai_config';
  static const String donate = 'donate';
  static const String donate_button = 'donate_button';
  static const String donate_description = 'donate_description';
  static const String about = 'about';
  static const String kzl = 'kzl';
  static const String tos = 'tos';
  static const String pp = 'pp';
  static const String license = 'license';
  static const String ai_platform_limitations = 'ai_platform_limitations';
  static const String internet_warning = 'internet_warning';
  static const String language = 'language';

  // Scan Viewer Screen
  static const String add = 'add';
  static const String save = 'save';
  static const String add_question = 'add_question';
  static const String share_button = 'share';
  static const String share_alert = 'share_alert';
  static const String rename = 'rename';
  static const String delete = 'delete';
  static const String share_question = 'share_question';
  static const String pdf = 'pdf';
  static const String images = 'images';
  static const String rename_text = 'rename_text';
  static const String delete_question = 'delete_question';
  static const String delete_text = 'delete_text';
  static const String rename_hint = 'rename_hint';
  static const String crop_and_rotate = 'crop_and_rotate';
  static const String reorder = 'reorder';
  static const String delete_page = 'delete_page';
  static const String deleted = 'deleted';
  static const String deleted_drive = 'deleted_drive';
  static const String failed_share_pdf = 'failed_share_pdf';
  static const String failed_share_images = 'failed_share_images';
  static const String add_pages_success = 'add_pages_success';
  static const String add_pages_failed = 'add_pages_failed';
  static const String rename_failed = 'rename_failed';
  static const String from_camera = 'from_camera';
  static const String from_photos = 'from_photo';

  // Reorder Screen
  static const String reorder_noun = 'reorder_noun';

  // MagicEyes Screen
  static const String extract = 'extract';
  static const String summarize = 'summarize';
  static const String proofread = 'proofread';
  static const String chat = 'chat';
  static const String extract_button = 'extract_button';
  static const String summarize_button = 'summarize_button';
  static const String proofread_button = 'proofread_button';
  static const String chat_message = 'chat_message';
  static const String summary_placeholder = 'summary_placeholder';
  static const String results_placeholder = 'results_placeholder';
  static const String extracted_placeholder = 'extracted_placeholder';
  static const String extracting_text = 'extracting_text';
  static const String generating_summary = 'generating_summary';
  static const String proofreading_document = 'proofreading_document';
  static const String processing_pages = 'processing_pages';

  // Donation Screen
  static const String thank_you = 'thank_you';
  static const String thank_you_message = 'thank_you_message';
  static const String donation_methods = 'donation_method';
  static const String monthly = 'monthly';
  static const String restore_purchases = 'restore_purchases';
  static const String other = 'other';
  static const String onetime_payment = 'onetime_payment';
  static const String already_donated_alert = 'already_donated_alert';
  static const String desktop_donation_attempt = 'desktop_donation_attempt';

  // AI Configuration Screen
  static const String ai_status = 'ai_status';
  static const String status_active = 'status_active';
  static const String status_inactive = 'status_inactive';
  static const String guide_and_info = 'guide_and_info';
  static const String what_is_this = 'what_is_this';
  static const String privacy_first = 'privacy_first';
  static const String how_to_get_one = 'how_to_get_one';
  static const String what_is_this_description = 'what_is_this_description';
  static const String privacy_first_description = 'privacy_first_description';
  static const String how_to_get_one_description = 'how_to_get_one_description';
  static const String api_key_added_success = 'api_key_added_success';
  static const String api_key_invalid = 'api_key_invalid';
  static const String api_key_removed = 'api_key_removed';
  static const String no_api_key = 'no_api_key';
  static const String go_to_ai_config = 'go_to_ai_config';
  static const String api_key_required = 'api_key_required';
  static const String no_api_detected = 'no_api_detected';

  // After scanning screen
  static const String success = 'success';
  static const String success_subtitle = 'success_subtitle';
  static const String success_body = 'success_body';

  // No scans widget
  static const String no_internet = 'no_internet';
  static const String no_scans = 'no_scans';
  static const String no_scans_yet = 'no_scans_yet';
  static const String no_scans_yet_text = 'no_scans_yet_text';
  static const String sign_in_text = 'sign_in_text';

  // Subscriptions
  static const String support_title = 'support_title';
  static const String support_subtitle = 'support_subtitle';
  static const String support_body = 'support_body';
  static const String support_benefits = 'support_benefits';
  static const String support_button = 'support_button';
  static const String support_now_button = 'support_now_button';
  static const String no_donation_options = 'no_donation_options';
  static const String restore_success = 'restore_success';
  static const String restore_non = 'restore_non';
  static const String restore_failed = 'restore_failed';
  static const String purchase_failed = 'purchase_failed';
  static const String purchase_success = 'purchase_success';
  static const String payment_pending = 'payment_pending';

  // Subscription Options
  static const String iap_supporter = 'iap_supporter';
  static const String iap_supporter_plus = 'iap_supporter_plus';
  static const String iap_supporter_super = 'iap_supporter_super';
  static const String iap_support_ultra = 'iap_supporter_ultra';
  static const String otp_max = 'otp_max';
  static const String default_support = 'default_support';
  static const String purchase_footer = 'purchase_footer';
  static const String per_month = 'per_month';

  static const Map<String, dynamic> EN = {
    title: 'SuperScan',
    pages: '%a page(s)',
    scan: 'Scan',
    options_alert: 'Options for',
    options_message: 'What would you like to do?',

    settings: 'Settings',
    google_account_for_sync: 'Google Account for Sync',
    not_signed_in: 'Not signed in',
    sign_in: 'Sign in with Google',
    sign_out: 'Sign out',
    get_on_dekstop: 'Get SuperScan on Desktop',
    ai_config: 'AI Configuration',
    donate: 'Donate',
    donate_button: 'Donate',
    donate_description: 'Support my work, remove ads, and get access to AI features on mobile',
    about: 'About',
    kzl: 'Made with ❤️ by Kaung Zin Lin',
    tos: 'Terms of Use',
    pp: 'Privacy Policy',
    license: 'License',
    close: 'Close',
    ai_platform_limitations: 'Due to platform limitations regarding OCR, you can only use AI features on mobile',
    internet_warning: 'Internet is required for sign-in and sync',
    language: 'Language',
    sign_out_question: 'Are you sure you want to sign out?',
    sign_out_success: 'Signed out',
    sign_out_failed: 'Failed to sign out',

    add: 'Add',
    cancel: 'Cancel',
    save: 'Save',
    add_question: 'How would you like to add more scans?',
    share_button: 'Share',
    share_alert: 'Share ',
    rename: 'Rename',
    delete: 'Delete',
    share_question: 'How would you like to share your document?',
    pdf: 'PDF',
    images: 'Images',
    rename_text: 'Rename scan',
    delete_question: 'Delete scan?',
    delete_text: 'will be permanently deleted.',
    rename_hint: 'Scan name',
    crop_and_rotate: 'Crop and Rotate',
    reorder: 'Reorder',
    delete_page: 'Delete this Page',
    done: 'Done',
    deleted: 'Deleted permanently',
    deleted_drive: 'Deleted from Google Drive',
    failed_share_pdf: 'Failed to share PDF: ',
    failed_share_images: 'Failed to share images: ',
    add_pages_success: 'Added pages successfully',
    add_pages_failed: 'Failed to add pages',
    rename_failed: 'Failed to rename',
    unexpected_error: 'Unexpected error:',
    from_camera: 'From Camera',
    from_photos: 'From Photos',

    reorder_noun: 'Reorder',

    extract: 'Extract',
    summarize: 'Summarize',
    proofread: 'Proofread',
    chat: 'Chat',
    extract_button: 'Extract Text',
    summarize_button: 'Generate Summary',
    proofread_button: 'Proofread Document',
    chat_message: 'Type a message...',
    clipboard_copy: 'Copied to clipboard',
    summary_placeholder: 'Summary will appear here.',
    results_placeholder: 'Results will appear here.',
    clipboard_tooltip: 'Copy',
    share_tooltip: 'Share',
    extracted_placeholder: 'Extracted text will appear here.',
    extracting_text: 'Extracting text...',
    generating_summary: 'Generating summary...',
    proofreading_document: 'Proofreading document...',
    processing_pages: 'Processing page(s)',

    thank_you: 'Thank You!',
    thank_you_message: 'Keeping SuperScan ad-free and paywall-free is the dream, but for now, those ads help me cover development costs and keep the app alive. If you want to help me out and get a cleaner, ad-free experience with access to AI features in return, pick a donation option below. Thanks for being awesome!',
    donation_methods: 'Select an amount to donate from the Apple App Store or the Google Play Store',
    monthly: 'Monthly Donations',
    other: 'Others',
    restore_purchases: 'Restore Purchases',
    onetime_payment: 'One-Time Payment',
    desktop_donation_attempt: 'You can only donate on mobile',
    payment_pending: 'Payment pending. Please complete your payment to unlock features.',

    ai_status: 'Current Status: ',
    status_active: 'Active',
    status_inactive: 'Inactive',
    guide_and_info: 'Guide & Information',
    what_is_this: 'What is this?',
    privacy_first: 'Privacy First',
    how_to_get_one: 'How to get one?',
    what_is_this_description: 'An OpenAI API key allows MagicEyes to securely use AI to summarize and analyze your documents. It works like a private access token for your personal OpenAI account.',
    privacy_first_description: 'We never see your key. Documents are sent directly from your device to OpenAI. You only pay for what you use, directly to OpenAI.',
    how_to_get_one_description: "1. Sign in to platform.openai.com\n2. Navigate to API Keys\n3. Create a 'Secret Key' and paste it above.",
    api_key_added_success: 'API Key Updated Successfully',
    api_key_invalid: 'Please enter a valid key',
    api_key_removed: 'API Key Removed',
    no_api_key: 'No key configured',
    go_to_ai_config: 'Go to AI Configuration',
    api_key_required: 'An API key is required for AI features.',
    no_api_detected: 'No API Key detected',

    success: 'Success!',
    success_subtitle: 'Your document has been exported!',
    success_body: "Keeping SuperScan ad-free is the dream, but for now, the ads I've implemented help me pay the bills. If you want to help me out, you can donate to remove ads and to get access to AI features.",

    no_internet: 'No Internet Connection',
    no_scans: 'No Scans',
    no_scans_yet: 'No Scans Yet',
    no_scans_yet_text: 'Start scanning by pressing “+”',
    sign_in_text: 'Sign in to get synced scans. Go to Settings > Sign In',

    support_title: 'Support SuperScan',
    support_subtitle: 'Donate to get access to AI features, remove ads, and support my work',
    support_body: 'Donate to get access to AI features, remove ads, and support my work',
    support_benefits: 'Unlock BYOK AI features, remove ads, and support my work.\nAll tiers provide the same features.',
    support_button: 'Support',
    support_now_button: 'Support Now',
    no_donation_options: 'No donation options available.',
    restore_success: 'Purchases restored successfully',
    restore_non: 'No purchases found',
    restore_failed: 'Failed to restore purchases',
    purchase_failed: 'Purchase failed or canceled. If Google says that your payment was successful but you still cannot access paid features, it maybe a pending/delayed payment. Please wait a few minutes and check back again by restarting the app.',
    purchase_success: 'Thank you for your support!',
    already_donated_alert: "You've already donated! Thank you for your support!",

    iap_supporter: 'Supporter',
    iap_supporter_plus: 'Supporter+',
    iap_supporter_super: 'Super Supporter',
    iap_support_ultra: 'Ultra Supporter',
    otp_max: 'Max (Lifetime)',
    default_support: 'Support',
    purchase_footer: 'Subscriptions renew automatically unless canceled. All tiers unlock the same features. Cancel anytime in Play Store settings.',
    per_month: '/mo'
  };

  static const Map<String, dynamic> MY = {
    title: 'SuperScan',
    pages: '%a မျက်နှာ',
    scan: 'စကင်ဖတ်မည်',
    options_alert: 'ရွေးချယ်စရာများ -',
    options_message: 'ဘာလုပ်ချင်လဲ။',
    other: 'အခြား',

    settings: 'ဆက်တင်များ',
    google_account_for_sync: 'Sync လုပ်ရန်အတွက် Google အကောင့်',
    not_signed_in: 'အကောင့်ဝင်မထားပါ',
    sign_in: 'Google ဖြင့် အကောင့်ဝင်မည်',
    sign_out: 'အကောင့်ထွက်မည်',
    get_on_dekstop: 'Desktop မှာ SuperScan ရယူလိုက်ပါ',
    ai_config: 'AI ဆက်တင်',
    donate: 'လှူဒန်းပံ့ပိုးခြင်း',
    donate_button: 'လှူဒန်းပံ့ပိုးမည်',
    donate_description: 'ကျွန်ုပ်၏အလုပ်ကို ပံ့ပိုးပါ၊ ကြော်ငြာများကို ဖယ်ရှားပါ၊ မိုဘိုင်းတွင် AI Feature များကို အသုံးပြုခွင့် ရယူပါ',
    about: 'အကြောင်း',
    kzl: 'ကောင်းဇင်လင်း မှ ❤️ ဖြင့် ဖန်တီးထားသည်',
    tos: 'စည်းကမ်းချက်များ',
    pp: 'ကိုယ်ရေးအချက်အလက်မူဝါဒ',
    license: 'လိုင်စင်',
    close: 'ပိတ်မည်',
    ai_platform_limitations: 'OCR နှင့်ပတ်သက်သည့် ပလက်ဖောင်းကန့်သတ်ချက်များကြောင့် AI Feature များကို မိုဘိုင်းတွင်သာ အသုံးပြုနိုင်ပါသည်',
    internet_warning: 'အကောင့်ဝင်ရန် နှင့် Sync လုပ်ရန် အင်တာနက် လိုအပ်ပါသည်',
    language: 'ဘာသာစကား',
    sign_out_question: 'ထွက်လိုသည်မှာ သေချာပါသလား။',
    sign_out_success: 'အကောင့်ထွက်သွားပြီ',
    sign_out_failed: 'အကောင့်ထွက်ရန် မအောင်မြင်ပါ',

    add: 'ထပ်ထည့်မည်',
    cancel: 'ပိတ်မည်',
    save: 'သိမ်းမည်',
    add_question: 'နောက်ထပ်စာမျက်နှာတွေကို ဘယ်လိုထည့်ချင်ပါလဲ။',
    share_button: 'မျှဝေမည်',
    share_alert: 'မျှဝေမည် - ',
    rename: 'နာမည်ပြောင်းမည်',
    delete: 'ဖျက်မည်',
    share_question: 'သင့်စာရွက်စာတမ်းကို သင်မည်ကဲ့သို့မျှဝေလိုသနည်း။',
    pdf: 'PDF ဖြင့်',
    images: 'ပုံများဖြင့်',
    rename_text: 'နာမည်ပြောင်းခြင်း',
    delete_question: 'ဖျက်ချင်ပါသလား။',
    delete_text: 'ကိုအပြီးတိုင် ဖျက်လိုက်ပါမည်။',
    rename_hint: 'အမည်ပြောင်းရန်',
    crop_and_rotate: 'ဖြတ်ခြင်း နှင့် လှည့်ခြင်း',
    reorder: 'ပြန်စီမည်',
    delete_page: 'ဤစာမျက်နှာကိုဖျက်မည်',
    done: 'သိမ်းမည်',
    deleted: 'အပြီးတိုင် ဖျက်လိုက်ပါပြီ',
    deleted_drive: 'DGoogle Drive မှ ဖျက်လိုက်ပါပြီ',
    failed_share_pdf: 'PDF မျှဝေ၍မရပါ -',
    failed_share_images: 'ပုံများ မျှဝေ၍မရပါ -',
    add_pages_success: 'စာမျက်နှာများကို အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ',
    add_pages_failed: 'စာမျက်နှာများ ထည့်၍မရပါ',
    rename_failed: 'အမည်ပြောင်း၍မရပါ',
    unexpected_error: 'မမျှော်လင့်ထားသော ပြဿနာ -',
    from_camera: 'ကင်မရာမှ',
    from_photos: 'ဓာတ်ပုံများမှ',

    reorder_noun: 'ပြန်စီခြင်း',

    extract: 'စာထုတ်ခြင်း',
    summarize: 'အကျဉ်းချုပ်ခြင်း',
    proofread: 'စိစစ်ပြင်ဆင်ခြင်း',
    chat: 'ချတ်',
    extract_button: 'စာထုတ်မည်',
    summarize_button: 'အကျဉ်းချုပ်ထုတ်ပေးမည်',
    proofread_button: 'စိစစ်ပြင်ဆင်မည်',
    chat_message: 'မက်ဆေ့ချ်တစ်ခု ရိုက်ထည့်ပါ...',
    clipboard_copy: 'ကလစ်ဘုတ်သို့ ကူးယူပြီးပါပြီ',
    clipboard_tooltip: 'ကူးမည်',
    share_tooltip: 'မျှဝေမည်',
    summary_placeholder: 'အကျဉ်းချုပ်ကို ဤနေရာတွင် ပေါ်လာပါမည်။',
    results_placeholder: 'ရလဒ်များကို ဤနေရာတွင် ပေါ်လာပါမည်။',
    extracted_placeholder: 'ထုတ်ယူထားသော စာသားကို ဤနေရာတွင် ပေါ်လာပါမည်။',
    generating_summary: 'အကျဉ်းချုပ်ကို ဖန်တီးနေသည်...',
    proofreading_document: 'စာရွက်စာတမ်း စိစစ်နေသည်...',
    extracting_text: 'စာသားကို ထုတ်ယူနေသည်...',
    processing_pages: 'စာမျက်နှာ(များ) ကို လုပ်ဆောင်နေသည်',
    go_to_ai_config: 'AI Configuration သို့ သွားမည်',
    api_key_required: 'AI လုပ်ဆောင်ချက်များအတွက် API key တစ်ခု လိုအပ်ပါသည်။',
    no_api_detected: 'API Key မတွေ့ပါ',

    desktop_donation_attempt: 'မိုဘိုင်းဖြင့်သာ လှူဒါန်းနိုင်ပါသည်။',
    thank_you: 'ကျေးဇူးတင်ပါသည်',
    thank_you_message: 'SuperScan ကို ကြော်ငြာမပါ၊ paywall မပါအောင်ထားဖို့က အိပ်မက်ပါ၊ ဒါပေမယ့် လောလောဆယ်တော့ အဲဒီကြော်ငြာတွေက ဖွံ့ဖြိုးတိုးတက်ရေးကုန်ကျစရိတ်တွေကို ကာမိစေပြီး အက်ပ်ကို အသက်ဝင်နေအောင် ကူညီပေးပါတယ်။ ကျွန်တော့်ကို ကူညီပေးပြီး AI လုပ်ဆောင်ချက်တွေကို ပြန်လည်အသုံးပြုခွင့်နဲ့အတူ ပိုမိုသန့်ရှင်းပြီး ကြော်ငြာမပါသော အတွေ့အကြုံကို ရယူချင်တယ်ဆိုရင် အောက်မှာ လှူဒါန်းမှုရွေးချယ်မှုတစ်ခုကို ရွေးချယ်ပါ။ အံ့သြဖွယ်ကောင်းအောင် ကူညီပေးတဲ့အတွက် ကျေးဇူးတင်ပါတယ်။',
    donation_methods: 'Apple App Store သို့မဟုတ် Google Play Store မှ လှူဒါန်းရန် ပမာဏကို ရွေးချယ်ပါ',
    monthly: 'လစဉ်လှူဒါန်းများ',
    restore_purchases: 'ဝယ်ယူမှုများကို ပြန်လည်ရယူပါ',
    onetime_payment: 'တစ်ကြိမ်တည်းငွေပေးချေမှု',
    payment_pending: 'ငွေပေးချေမှု ဆိုင်းငံ့ထားပါသည်။ ဝန်ဆောင်မှုများ ရယူရန်အတွက် ငွေပေးချေမှုကို အပြီးသတ်ပါ။',

    ai_status: 'လက်ရှိအခြေအနေ -',
    status_active: 'အသက်ဝင်သည်',
    status_inactive: 'မလှုပ်မရှား',
    guide_and_info: 'လမ်းညွှန် နှင့် အချက်အလက်',
    what_is_this: 'လမ်းညွှန် နှင့် အချက်အလက်',
    privacy_first: 'ကိုယ်ရေးကိုယ်တာ ပထမ',
    how_to_get_one: 'တစ်ခုကို ဘယ်လိုရနိုင်မလဲ။',
    what_is_this_description: 'OpenAI API သော့တစ်ခုသည် MagicEyes သည် သင့်စာရွက်စာတမ်းများကို အကျဉ်းချုပ်နှင့်ခွဲခြမ်းစိတ်ဖြာရန် AI ကို လုံခြုံစွာအသုံးပြုရန် ခွင့်ပြုသည်။ ၎င်းသည် သင်၏ကိုယ်ပိုင် OpenAI အကောင့်အတွက် သီးသန့်ဝင်ရောက်ခွင့် တိုကင်တစ်ခုကဲ့သို့ အလုပ်လုပ်ပါသည်။',
    privacy_first_description: 'API Key ကို ငါတို့ဘယ်တော့မှ မတွေ့ဘူး။ စာရွက်စာတမ်းများကို သင့်စက်မှ OpenAI သို့ တိုက်ရိုက်ပေးပို့ပါသည်။ သင်အသုံးပြုသည့်အရာအတွက်သာ OpenAI သို့ တိုက်ရိုက်ပေးဆောင်ပါသည်။',
    how_to_get_one_description: "၁။ platform.openai.com သို့ လက်မှတ်ထိုးဝင်ပါ\n၂။ API ကီးများ\n၃။ 'လျှို့ဝှက်ကီး' ကို ဖန်တီးပြီး ၎င်းကို အပေါ်မှ ကူးထည့်ပါ။",
    api_key_added_success: 'API ကီးကို အောင်မြင်စွာ ထည့်သွင်းခဲ့သည်',
    api_key_invalid: 'ကျေးဇူးပြု၍ တရားဝင် API Key တစ်ခုထည့်ပါ',
    api_key_removed: 'API ကီးကို ဖယ်ရှားလိုက်ပါပြီ',
    no_api_key: 'API Key မရှိ',

    success: 'အောင်မြင်သည်',
    success_subtitle: 'သင့်စာရွက်စာတမ်းကို ထုတ်ယူပြီးပါပြီ။',
    success_body: "SuperScan ကို ကြော်ငြာမပါဘဲ ထားရှိခြင်းသည် အိပ်မက်ဖြစ်သည်၊ သို့သော် ယခုအခါတွင်၊ ကျွန်ုပ်လုပ်ဆောင်ခဲ့သော ကြော်ငြာများသည် ငွေတောင်းခံလွှာများကို ပေးဆောင်ရန် ကူညီပေးပါသည်။ ကျွန်ုပ်အား ကူညီလိုပါက၊ ကြော်ငြာများကို ဖယ်ရှားရန်နှင့် AI ဝန်ဆောင်မှုများသို့ ဝင်ရောက်ခွင့်ရရှိရန် လှူဒါန်းနိုင်ပါသည်။",

    no_internet: 'အင်တာနက်ချိတ်ဆက်မှုမရှိပါ',
    no_scans: 'စကင်ဖတ်ခြင်း မရှိပါ',
    no_scans_yet: 'စကင်ဖတ်ခြင်း မရှိသေးပါ',
    no_scans_yet_text: '“+” ကို နှိပ်ခြင်းဖြင့် စကင်ဖတ်ခြင်း စတင်ပါ',
    sign_in_text: 'စင့်ခ်လုပ်ထားသော စကင်ဖတ်မှုများကို ရယူရန် အကောင့်ဝင်ပါ။ ဆက်တင်များ > အကောင့်ဝင်ရန် သို့ သွားပါ။',

    support_title: 'SuperScan ကို ပံ့ပိုးပါ',
    support_subtitle: 'AI လုပ်ဆောင်ချက်များကို အသုံးပြုခွင့်ရရန်၊ ကြော်ငြာများကို ဖယ်ရှားရန်နှင့် ကျွန်ုပ်၏အလုပ်ကို ပံ့ပိုးရန် လှူဒါန်းပါ။',
    support_body: 'AI လုပ်ဆောင်ချက်များကို အသုံးပြုခွင့်ရရန်၊ ကြော်ငြာများကို ဖယ်ရှားရန်နှင့် ကျွန်ုပ်၏အလုပ်ကို ပံ့ပိုးရန် လှူဒါန်းပါ။',
    support_benefits: 'BYOK AI လုပ်ဆောင်ချက်များကို လော့ခ်ဖွင့်ပါ၊ ကြော်ငြာများကို ဖယ်ရှားပါ၊ ကျွန်ုပ်၏အလုပ်ကို ပံ့ပိုးပါ။\nအဆင့်အားလုံးသည် တူညီသောလုပ်ဆောင်ချက်များကို ပေးဆောင်ပါသည်။',
    support_button: 'ပံ့ပိုးမည် -',
    support_now_button: 'ယခုပံ့ပိုးမည် -',
    no_donation_options: 'ရွေးချယ်စရာများ မရှိပါ။',
    restore_success: 'ဝယ်ယူမှုများကို အောင်မြင်စွာ ပြန်လည်ရယူပြီးပါပြီ',
    restore_non: 'ဝယ်ယူမှုများ မတွေ့ပါ',
    restore_failed: 'ဝယ်ယူမှုများကို ပြန်လည်ရယူ၍မရပါ',
    purchase_failed: 'ဝယ်ယူမှု မအောင်မြင်ပါ သို့မဟုတ် ပယ်ဖျက်လိုက်ပါပြီ။ Google က သင့်ငွေပေးချေမှု အောင်မြင်သည်ဟု ပြောသော်လည်း အခကြေးငွေပေးရသည့် ဝန်ဆောင်မှုများကိုသာ အသုံးပြု၍ မရနိုင်သေးပါက၊ ၎င်းသည် ငွေပေးချေမှု ဆိုင်းငံ့ထားခြင်း/နှောင့်နှေးခြင်း ဖြစ်နိုင်သည်။ မိနစ်အနည်းငယ်စောင့်ပြီး အက်ပ်ကို ပြန်လည်စတင်ခြင်းဖြင့် ပြန်လည်စစ်ဆေးပါ။',
    purchase_success: 'သင့်ရဲ့ပံ့ပိုးမှုအတွက် ကျေးဇူးတင်ပါတယ်။',
    already_donated_alert: "သင်လှူဒါန်းပြီးပါပြီ။ သင်၏ပံ့ပိုးမှုအတွက် ကျေးဇူးတင်ပါသည်။",

    iap_supporter: 'ထောက်ပံ့သူ',
    iap_supporter_plus: 'ထောက်ပံ့သူ+',
    iap_supporter_super: 'စူပါ ထောက်ပံ့သူ',
    iap_support_ultra: 'အာထရာ ထောက်ပံ့သူ',
    otp_max: 'မက်စ် - Max (တစ်သက်တာ)',
    default_support: 'ထောက်ပံ့သူ',
    purchase_footer: 'Subscriptions များကို ပယ်ဖျက်ခြင်းမရှိပါက အလိုအလျောက် သက်တမ်းတိုးပါသည်။ အဆင့်အားလုံးသည် တူညီသောအင်္ဂါရပ်များကို လော့ခ်ဖွင့်ပေးပါသည်။ Play Store ဆက်တင်များတွင် အချိန်မရွေး ပယ်ဖျက်နိုင်ပါသည်။',
    per_month: ' (လစဥ်)',

  };

  static const Map<String, dynamic> ZH = {
    title: 'SuperScan',
    pages: '%a 页',
    scan: '扫描',
    options_alert: 'Options for',
    options_message: '你想做什么？',

    settings: '设置',
    google_account_for_sync: '用于同步的 Google 账户',
    not_signed_in: '尚未登录',
    sign_in: '使用 Google 登录',
    sign_out: '退出',
    get_on_dekstop: '在电脑上下载 SuperScan',
    ai_config: 'AI 配置',
    donate: '善款',
    donate_button: '捐款',
    donate_description: '支持我的工作，移除广告，并解锁移动端的人工智能功能',
    about: '关于',
    kzl: '由 Kaung Zin Lin 倾情制作',
    tos: '使用条款',
    pp: '隐私政策',
    license: '许可',
    close: '关闭',
    ai_platform_limitations: '由于平台在OCR方面的限制，您只能在移动端使用AI功能',
    internet_warning: '登录和同步需要联网',
    language: '语言',
    sign_out_question: '您确定要注销吗？',
    sign_out_success: '已注销',
    sign_out_failed: '注销失败',

    add: '添加',
    cancel: '取消',
    save: '保存',
    add_question: '您想添加更多扫描件吗？',
    share_button: '分享',
    share_alert: '分享 -',
    rename: '重命名',
    delete: '删除',
    share_question: '您希望如何分享您的文档？',
    pdf: 'PDF格式',
    images: '作为图片',
    rename_text: '重命名扫描',
    delete_question: '删除扫描？',
    delete_text: '将被永久删除.',
    rename_hint: '扫描名称',
    crop_and_rotate: '裁剪和旋转',
    reorder: '重新排序',
    delete_page: '删除此页面',
    done: '完成',
    deleted: '已永久删除',
    deleted_drive: '已从 Google Drive 中删除',
    failed_share_pdf: '无法分享 PDF - ',
    failed_share_images: '无法分享图片 - ',
    add_pages_success: '页面已成功添加',
    add_pages_failed: '添加页面失败',
    rename_failed: '重命名失败',
    unexpected_error: '意外错误 -',
    from_camera: '来自相机',
    from_photos: '来自照片',

    reorder_noun: '重新排序',

    extract: '摘录',
    summarize: '总结',
    proofread: '校对',
    chat: '聊天',
    extract_button: '提取文本',
    summarize_button: '生成摘要',
    proofread_button: '校对文档',
    chat_message: '请输入消息...',
    clipboard_copy: '已复制到剪贴板',
    summary_placeholder: '摘要将显示在此处。',
    results_placeholder: '结果将显示在此处。',
    clipboard_tooltip: '复制',
    share_tooltip: '分享',
    extracted_placeholder: '提取的文本将显示在此处。',
    extracting_text: '正在提取文本...',
    generating_summary: '正在生成摘要...',
    proofreading_document: '正在校对文档...',
    processing_pages: '正在处理页面',

    thank_you: '谢谢！',
    thank_you_message: '让 SuperScan 保持无广告、无付费墙是我的梦想，但目前这些广告帮助我承担了开发成本，并让应用得以持续运营。如果您愿意支持我，并希望获得更清爽的无广告体验以及使用 AI 功能的权限，请选择下方的捐赠选项。感谢您的支持！',
    donation_methods: '请在 Apple App Store 或 Google Play 商店中选择捐赠金额',
    monthly: '每月捐款',
    other: '其他',
    restore_purchases: '恢复购买',
    onetime_payment: '一次性付款',
    already_donated_alert: "您已经捐款了！感谢您的支持",

    ai_status: '当前状态 - ',
    status_active: '已启用',
    status_inactive: '已停用',
    guide_and_info: '指南与信息',
    what_is_this: '这是什么？',
    privacy_first: '隐私至上',
    how_to_get_one: '如何获得一个？',
    what_is_this_description: 'OpenAI API密钥可让MagicEyes安全地利用人工智能对您的文档进行摘要和分析。它相当于您个人OpenAI账户的私有访问令牌。',
    privacy_first_description: '我们绝不会看到您的密钥。文档会直接从您的设备发送至 OpenAI。您只需按实际使用量付费，并直接向 OpenAI 支付。',
    how_to_get_one_description: "1. 登录 platform.openai.com\n2. 进入“API 密钥”页面\n3. 创建一个“密钥”，并将它粘贴到上方。",
    api_key_added_success: 'API 密钥已成功更新',
    api_key_invalid: '请输入有效的密钥',
    api_key_removed: 'API 密钥已被移除',
    no_api_key: '未配置密钥',
    go_to_ai_config: '转到 AI 配置',
    api_key_required: '使用 AI 功能需要 API 密钥。',
    no_api_detected: '未检测到 API 密钥',
    desktop_donation_attempt: '您只能通过手机进行捐赠',

    success: '成功！',
    success_subtitle: '您的文档已导出！',
    success_body: "让 SuperScan 保持无广告状态是我的梦想，但目前，我添加的广告能帮助我维持生计。如果您愿意支持我，可以进行捐赠以移除广告并解锁 AI 功能。",

    no_internet: '没有互联网连接',
    no_scans: '无扫描件',
    no_scans_yet: '尚无扫描件',
    no_scans_yet_text: '点击“+”开始扫描',
    sign_in_text: '登录以同步扫描文件。请前往“设置” > “登录”',

    support_title: '支持 SuperScan',
    support_subtitle: '捐款即可解锁AI功能、去除广告，并支持我的工作',
    support_body: '捐款即可解锁AI功能、去除广告，并支持我的工作',
    support_benefits: '解锁 BYOK (请自备钥匙) AI 功能，移除广告，并支持我的工作。\n所有档位均提供相同的功能。',
    support_button: '支持',
    support_now_button: '立即获取支持',
    no_donation_options: '目前没有捐赠选项。',
    restore_success: '已成功恢复购买记录',
    restore_non: '未找到相关商品',
    restore_failed: '无法恢复已购买内容',
    purchase_failed: '购买失败或已被取消。如果 Google 显示您的支付已成功，但您仍无法使用付费功能，可能是支付处于待处理或延迟状态。请稍等几分钟，然后重启应用后再次尝试。',
    purchase_success: '感谢您的支持！',
    payment_pending: '付款待处理。请完成付款以解锁功能。',

    iap_supporter: '支持者',
    iap_supporter_plus: '支持者+',
    iap_supporter_super: '超级支持者',
    iap_support_ultra: '超级支持者',
    otp_max: '马克斯 (终身)',
    default_support: '支持',
    purchase_footer: '除非取消订阅，否则订阅将自动续订。所有套餐均可解锁相同的功能。您可随时在 Google Play 设置中取消订阅。',
    per_month: '/月'
  };

  static const Map<String, dynamic> ZH_HANT = {
    title: 'SuperScan',
    pages: '%a 頁',
    scan: '掃描',
    options_alert: '選項',
    options_message: '您想要做什麼？',

    settings: '設定',
    google_account_for_sync: '用於同步的 Google 帳戶',
    not_signed_in: '尚未登入',
    sign_in: '使用 Google 登入',
    sign_out: '登出',
    get_on_dekstop: '在桌面版取得 SuperScan',
    ai_config: 'AI 設定',
    donate: '贊助',
    donate_button: '贊助',
    donate_description: '支持我的開發、移除廣告，並在手機上使用 AI 功能',
    about: '關於',
    kzl: '由 Kaung Zin Lin 用 ❤️ 製作',
    tos: '使用條款',
    pp: '隱私政策',
    license: '授權',
    close: '關閉',
    ai_platform_limitations: '由於 OCR 平台限制，AI 功能僅可在手機上使用',
    internet_warning: '登入與同步需要網路連線',
    language: '語言',
    sign_out_question: '您確定要登出嗎？',
    sign_out_success: '已登出',
    sign_out_failed: '登出失敗',

    add: '新增',
    cancel: '取消',
    save: '儲存',
    add_question: '您想如何新增更多掃描？',
    share_button: '分享',
    share_alert: '分享 ',
    rename: '重新命名',
    delete: '刪除',
    share_question: '您想如何分享您的文件？',
    pdf: 'PDF',
    images: '圖片',
    rename_text: '重新命名掃描',
    delete_question: '刪除此掃描？',
    delete_text: '將被永久刪除。',
    rename_hint: '掃描名稱',
    crop_and_rotate: '裁切與旋轉',
    reorder: '重新排序',
    delete_page: '刪除此頁',
    done: '完成',
    deleted: '已永久刪除',
    deleted_drive: '已從 Google Drive 刪除',
    failed_share_pdf: '分享 PDF 失敗：',
    failed_share_images: '分享圖片失敗：',
    add_pages_success: '已成功新增頁面',
    add_pages_failed: '新增頁面失敗',
    rename_failed: '重新命名失敗',
    unexpected_error: '發生未預期錯誤：',
    from_camera: '從相機',
    from_photos: '從相簿',

    reorder_noun: '重新排序',

    extract: '擷取',
    summarize: '摘要',
    proofread: '校對',
    chat: '聊天',
    extract_button: '擷取文字',
    summarize_button: '產生摘要',
    proofread_button: '校對文件',
    chat_message: '輸入訊息...',
    clipboard_copy: '已複製到剪貼簿',
    summary_placeholder: '摘要將顯示於此。',
    results_placeholder: '結果將顯示於此。',
    clipboard_tooltip: '複製',
    share_tooltip: '分享',
    extracted_placeholder: '擷取文字將顯示於此。',
    extracting_text: '正在擷取文字...',
    generating_summary: '正在產生摘要...',
    proofreading_document: '正在校對文件...',
    processing_pages: '正在處理頁面',

    thank_you: '感謝您！',
    thank_you_message: '讓 SuperScan 保持無廣告、無付費牆是我的夢想，但目前這些廣告幫助我負擔開發成本並維持 App 運作。如果您願意支持我，並獲得更乾淨的無廣告體驗與 AI 功能存取權，請選擇下方的贊助方案。謝謝您的支持！',
    donation_methods: '請從 Apple App Store 或 Google Play Store 選擇贊助金額',
    monthly: '每月贊助',
    other: '其他',
    restore_purchases: '恢復購買',
    onetime_payment: '一次性付款',
    desktop_donation_attempt: '僅可在手機上贊助',
    payment_pending: '付款處理中。請完成付款以解鎖功能。',

    ai_status: '目前狀態：',
    status_active: '已啟用',
    status_inactive: '未啟用',
    guide_and_info: '指南與資訊',
    what_is_this: '這是什麼？',
    privacy_first: '隱私優先',
    how_to_get_one: '如何取得？',
    what_is_this_description: 'OpenAI API 金鑰可讓 MagicEyes 安全地使用 AI 來摘要與分析您的文件。它就像是您個人 OpenAI 帳戶的私人存取憑證。',
    privacy_first_description: '我們永遠不會看到您的金鑰。文件會直接從您的裝置傳送到 OpenAI。您只需直接向 OpenAI 支付實際使用費用。',
    how_to_get_one_description: "1. 登入 platform.openai.com\n2. 前往 API Keys\n3. 建立「Secret Key」並貼到上方。",
    api_key_added_success: 'API 金鑰已成功更新',
    api_key_invalid: '請輸入有效的金鑰',
    api_key_removed: 'API 金鑰已移除',
    no_api_key: '尚未設定金鑰',
    go_to_ai_config: '前往 AI 設定',
    api_key_required: 'AI 功能需要 API 金鑰。',
    no_api_detected: '未偵測到 API 金鑰',

    success: '成功！',
    success_subtitle: '您的文件已匯出！',
    success_body: '讓 SuperScan 保持無廣告是我的夢想，但目前廣告收入幫助我支付帳單。如果您願意支持我，可以透過贊助移除廣告並取得 AI 功能。',

    no_internet: '沒有網路連線',
    no_scans: '沒有掃描',
    no_scans_yet: '尚無掃描',
    no_scans_yet_text: '按下「+」開始掃描',
    sign_in_text: '登入以同步掃描內容。前往 設定 > 登入',

    support_title: '支持 SuperScan',
    support_subtitle: '贊助即可使用 AI 功能、移除廣告並支持我的開發',
    support_body: '贊助即可使用 AI 功能、移除廣告並支持我的開發',
    support_benefits: '解鎖 BYOK AI 功能、移除廣告並支持我的開發。\n所有方案提供相同功能。',
    support_button: '支持',
    support_now_button: '立即支持',
    no_donation_options: '目前沒有可用的贊助方案。',
    restore_success: '已成功恢復購買',
    restore_non: '找不到任何購買紀錄',
    restore_failed: '恢復購買失敗',
    purchase_failed: '購買失敗或已取消。如果 Google 顯示付款成功但您仍無法使用付費功能，可能是付款延遲處理中。請稍候幾分鐘後重新啟動 App 再查看。',
    purchase_success: '感謝您的支持！',
    already_donated_alert: '您已經贊助過了！感謝您的支持！',

    iap_supporter: '支持者',
    iap_supporter_plus: '支持者+',
    iap_supporter_super: '超級支持者',
    iap_support_ultra: '終極支持者',
    otp_max: '最高級（終身）',
    default_support: '支持',
    purchase_footer: '訂閱將自動續訂，除非取消。所有方案解鎖相同功能。可隨時於 Play 商店設定中取消。',
    per_month: '/月',
  };

  static const Map<String, dynamic> VI = {
    title: 'SuperScan',
    pages: '%a trang',
    scan: 'Quét',
    options_alert: 'Tùy chọn cho',
    options_message: 'Bạn muốn làm gì?',

    settings: 'Cài đặt',
    google_account_for_sync: 'Tài khoản Google để đồng bộ',
    not_signed_in: 'Chưa đăng nhập',
    sign_in: 'Đăng nhập với Google',
    sign_out: 'Đăng xuất',
    get_on_dekstop: 'Tải SuperScan trên máy tính',
    ai_config: 'Cấu hình AI',
    donate: 'Ủng hộ',
    donate_button: 'Ủng hộ',
    donate_description: 'Ủng hộ công việc của tôi, xóa quảng cáo và mở khóa tính năng AI trên điện thoại',
    about: 'Giới thiệu',
    kzl: 'Được tạo với ❤️ bởi Kaung Zin Lin',
    tos: 'Điều khoản sử dụng',
    pp: 'Chính sách riêng tư',
    license: 'Giấy phép',
    close: 'Đóng',
    ai_platform_limitations: 'Do giới hạn nền tảng liên quan đến OCR, bạn chỉ có thể dùng tính năng AI trên điện thoại',
    internet_warning: 'Cần có Internet để đăng nhập và đồng bộ',
    language: 'Ngôn ngữ',
    sign_out_question: 'Bạn có chắc muốn đăng xuất?',
    sign_out_success: 'Đã đăng xuất',
    sign_out_failed: 'Đăng xuất thất bại',

    add: 'Thêm',
    cancel: 'Hủy',
    save: 'Lưu',
    add_question: 'Bạn muốn thêm bản quét bằng cách nào?',
    share_button: 'Chia sẻ',
    share_alert: 'Chia sẻ ',
    rename: 'Đổi tên',
    delete: 'Xóa',
    share_question: 'Bạn muốn chia sẻ tài liệu như thế nào?',
    pdf: 'PDF',
    images: 'Hình ảnh',
    rename_text: 'Đổi tên bản quét',
    delete_question: 'Xóa bản quét này?',
    delete_text: 'sẽ bị xóa vĩnh viễn.',
    rename_hint: 'Tên bản quét',
    crop_and_rotate: 'Cắt và xoay',
    reorder: 'Sắp xếp lại',
    delete_page: 'Xóa trang này',
    done: 'Xong',
    deleted: 'Đã xóa vĩnh viễn',
    deleted_drive: 'Đã xóa khỏi Google Drive',
    failed_share_pdf: 'Chia sẻ PDF thất bại: ',
    failed_share_images: 'Chia sẻ hình ảnh thất bại: ',
    add_pages_success: 'Đã thêm trang thành công',
    add_pages_failed: 'Thêm trang thất bại',
    rename_failed: 'Đổi tên thất bại',
    unexpected_error: 'Lỗi không mong muốn:',
    from_camera: 'Từ máy ảnh',
    from_photos: 'Từ thư viện ảnh',

    reorder_noun: 'Sắp xếp lại',

    extract: 'Trích xuất',
    summarize: 'Tóm tắt',
    proofread: 'Hiệu đính',
    chat: 'Trò chuyện',
    extract_button: 'Trích xuất văn bản',
    summarize_button: 'Tạo tóm tắt',
    proofread_button: 'Hiệu đính tài liệu',
    chat_message: 'Nhập tin nhắn...',
    clipboard_copy: 'Đã sao chép vào bộ nhớ tạm',
    summary_placeholder: 'Bản tóm tắt sẽ xuất hiện ở đây.',
    results_placeholder: 'Kết quả sẽ xuất hiện ở đây.',
    clipboard_tooltip: 'Sao chép',
    share_tooltip: 'Chia sẻ',
    extracted_placeholder: 'Văn bản trích xuất sẽ xuất hiện ở đây.',
    extracting_text: 'Đang trích xuất văn bản...',
    generating_summary: 'Đang tạo tóm tắt...',
    proofreading_document: 'Đang hiệu đính tài liệu...',
    processing_pages: 'Đang xử lý trang',

    thank_you: 'Cảm ơn bạn!',
    thank_you_message: 'Giữ cho SuperScan không quảng cáo và không khóa tính năng trả phí là ước mơ của tôi, nhưng hiện tại quảng cáo giúp tôi trang trải chi phí phát triển và duy trì ứng dụng. Nếu bạn muốn ủng hộ tôi và nhận trải nghiệm sạch hơn, không quảng cáo cùng quyền truy cập AI, hãy chọn một gói bên dưới. Cảm ơn bạn rất nhiều!',
    donation_methods: 'Chọn số tiền ủng hộ từ Apple App Store hoặc Google Play Store',
    monthly: 'Ủng hộ hàng tháng',
    other: 'Khác',
    restore_purchases: 'Khôi phục mua hàng',
    onetime_payment: 'Thanh toán một lần',
    desktop_donation_attempt: 'Bạn chỉ có thể ủng hộ trên điện thoại',
    payment_pending: 'Thanh toán đang chờ xử lý. Vui lòng hoàn tất thanh toán để mở khóa tính năng.',

    ai_status: 'Trạng thái hiện tại: ',
    status_active: 'Đang hoạt động',
    status_inactive: 'Không hoạt động',
    guide_and_info: 'Hướng dẫn & Thông tin',
    what_is_this: 'Đây là gì?',
    privacy_first: 'Ưu tiên quyền riêng tư',
    how_to_get_one: 'Làm sao để có?',
    what_is_this_description: 'Khóa API OpenAI cho phép MagicEyes sử dụng AI an toàn để tóm tắt và phân tích tài liệu của bạn. Nó hoạt động như mã truy cập riêng tư cho tài khoản OpenAI cá nhân của bạn.',
    privacy_first_description: 'Chúng tôi không bao giờ thấy khóa của bạn. Tài liệu được gửi trực tiếp từ thiết bị của bạn đến OpenAI. Bạn chỉ trả tiền trực tiếp cho OpenAI theo mức sử dụng.',
    how_to_get_one_description: "1. Đăng nhập platform.openai.com\n2. Vào mục API Keys\n3. Tạo 'Secret Key' và dán vào bên trên.",
    api_key_added_success: 'Đã cập nhật khóa API thành công',
    api_key_invalid: 'Vui lòng nhập khóa hợp lệ',
    api_key_removed: 'Đã xóa khóa API',
    no_api_key: 'Chưa cấu hình khóa',
    go_to_ai_config: 'Đi tới Cấu hình AI',
    api_key_required: 'Cần có khóa API để dùng tính năng AI.',
    no_api_detected: 'Không phát hiện khóa API',

    success: 'Thành công!',
    success_subtitle: 'Tài liệu của bạn đã được xuất!',
    success_body: 'Giữ SuperScan không quảng cáo là ước mơ của tôi, nhưng hiện tại quảng cáo giúp tôi chi trả chi phí. Nếu bạn muốn ủng hộ tôi, bạn có thể quyên góp để xóa quảng cáo và mở khóa tính năng AI.',

    no_internet: 'Không có kết nối Internet',
    no_scans: 'Không có bản quét',
    no_scans_yet: 'Chưa có bản quét',
    no_scans_yet_text: 'Bắt đầu quét bằng cách nhấn “+”',
    sign_in_text: 'Đăng nhập để đồng bộ bản quét. Vào Cài đặt > Đăng nhập',

    support_title: 'Ủng hộ SuperScan',
    support_subtitle: 'Ủng hộ để dùng AI, xóa quảng cáo và hỗ trợ công việc của tôi',
    support_body: 'Ủng hộ để dùng AI, xóa quảng cáo và hỗ trợ công việc của tôi',
    support_benefits: 'Mở khóa tính năng AI BYOK, xóa quảng cáo và hỗ trợ công việc của tôi.\nTất cả các gói đều có cùng tính năng.',
    support_button: 'Ủng hộ',
    support_now_button: 'Ủng hộ ngay',
    no_donation_options: 'Không có gói ủng hộ nào khả dụng.',
    restore_success: 'Đã khôi phục mua hàng thành công',
    restore_non: 'Không tìm thấy giao dịch mua nào',
    restore_failed: 'Khôi phục mua hàng thất bại',
    purchase_failed: 'Mua hàng thất bại hoặc đã hủy. Nếu Google báo thanh toán thành công nhưng bạn vẫn chưa truy cập được tính năng trả phí, có thể thanh toán đang chờ xử lý. Vui lòng đợi vài phút rồi khởi động lại ứng dụng.',
    purchase_success: 'Cảm ơn sự ủng hộ của bạn!',
    already_donated_alert: 'Bạn đã ủng hộ rồi! Cảm ơn bạn rất nhiều!',

    iap_supporter: 'Người ủng hộ',
    iap_supporter_plus: 'Người ủng hộ+',
    iap_supporter_super: 'Siêu người ủng hộ',
    iap_support_ultra: 'Người ủng hộ tối thượng',
    otp_max: 'Cao nhất (Trọn đời)',
    default_support: 'Ủng hộ',
    purchase_footer: 'Gói đăng ký sẽ tự động gia hạn trừ khi bị hủy. Tất cả các gói mở khóa cùng tính năng. Có thể hủy bất cứ lúc nào trong cài đặt Play Store.',
    per_month: '/tháng',
  };
}