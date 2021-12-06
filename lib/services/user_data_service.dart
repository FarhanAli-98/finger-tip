
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ball_on_a_budget_planner/models/user.dart';
import 'package:ball_on_a_budget_planner/services/base_service.dart';

class UserDataService extends BaseUserDataService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  UserModel user;

  
  @override
  void dispose() {}

  @override
  Future<UserModel> getUserProfile(String uid) async{
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('NewUsersList').doc(uid).get();
      UserModel currentUser = UserModel.fromFirestore(documentSnapshot);
     
      return currentUser;
    } catch (e) {
      print(e);
      return null;
    }
    }
  
    @override
    Future<UserModel> saveToFirebase({
      String uid, 
      String name, 
      String email, 
      String profileImageUrl, 
      String tokenId, 
      String loggedInVia}) async{
        try {
          DocumentReference ref = db.collection('NewUsersList').doc(uid);
          var data = {
            'accountStatus': 'Active',
            'isBlocked': false,
            'uid': uid,
            'name': name,
            'email': email,
            'profileImageUrl': profileImageUrl != null ? profileImageUrl : '',
            'tokenId': tokenId,
            'loggedInVia': loggedInVia,
          };
          ref.set(data, SetOptions(merge: true));
          final DocumentSnapshot currentDoc = await ref.get();
          user = UserModel.fromFirestore(currentDoc);
        } catch (e) {
           print('failed to save user details:: $e');
          user = null;
        }
        return user;
  }
}