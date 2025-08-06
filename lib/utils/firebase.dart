import 'package:firebase_core/firebase_core.dart';
import 'package:social_app_1/firebase_options.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
