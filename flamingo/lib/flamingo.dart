library flamingo;

import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, DocumentReference, FirebaseFirestore, Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

export 'src/batch.dart';
export 'src/collection_paging.dart';
export 'src/collection_paging_listener.dart';
export 'src/constants.dart';
export 'src/distributed_counter.dart';
export 'src/document_accessor.dart';
export 'src/enum/execute_type.dart';
export 'src/helper/helper.dart';
export 'src/master/master.dart';
export 'src/model/collection.dart';
export 'src/model/counter.dart';
export 'src/model/document.dart';
export 'src/model/increment.dart';
export 'src/model/model.dart';
export 'src/model/storage_file.dart';
export 'src/run_transaction.dart';
export 'src/storage.dart';
export 'src/type/type.dart';

class Flamingo {
  static Flamingo instance = Flamingo();
  static Future<void> initializeApp({
    String name,
    FirebaseOptions options,
    Settings settings,
    String rootPath,
  }) async {
    await Firebase.initializeApp(name: name, options: options);
    overrideWithSetting(settings: settings, rootPath: rootPath);
  }

  static void overrideWithSetting({
    FirebaseFirestore firestoreInstance,
    FirebaseStorage storageInstance,
    Settings settings,
    String rootPath,
  }) {
    if (settings != null) {
      FirebaseFirestore.instance.settings = settings;
    }
    instance._firestore = firestoreInstance ?? FirebaseFirestore.instance;
    instance._firebaseStorage = storageInstance ?? FirebaseStorage.instance;
    instance._rootReference = instance.firestore.doc(rootPath ?? '/');
  }

  DocumentReference get rootReference => _rootReference;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get firebaseStorage => _firebaseStorage;

  DocumentReference _rootReference;
  FirebaseFirestore _firestore;
  FirebaseStorage _firebaseStorage;
}

DocumentReference get rootReference => Flamingo.instance.rootReference;
FirebaseFirestore get firestoreInstance => Flamingo.instance.firestore;
FirebaseStorage get storageInstance => Flamingo.instance.firebaseStorage;
CollectionReference collectionReference(String path) =>
    Flamingo.instance.rootReference.collection(path);
