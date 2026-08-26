package ba.skipass.skipass_mobile

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (ne FlutterActivity) je obavezan jer flutter_stripe
// interno prikazuje PaymentSheet kao Android Fragment.
class MainActivity : FlutterFragmentActivity()
