import 'package:flutter/material.dart';
import 'package:usmfoodsaver/Reward%20System%20Module/invite.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferFriends extends StatefulWidget {
  @override
  State<ReferFriends> createState() => _ReferFriends();
}

class _ReferFriends extends State<ReferFriends> {
  User? user;
  Future<User?>? user2;
  late DatabaseReference userRef1;
  late DatabaseReference userRef2;
  int executionCounter = 0;
  TextEditingController inviteCodeController = TextEditingController();
  int referTime = 0;
  final pointsController = TextEditingController();

  Future<User?> getUserByStudentUid(String studentUid) async {
    try {
      // Fetch the user by UID from the 'Student' node
      DataSnapshot snapshot = (await FirebaseDatabase.instance
          .reference()
          .child('Student')
          .child(studentUid)
          .once()) as DataSnapshot;

      if (snapshot.value != null) {
        String uid = studentUid;
        if (uid != null) {
          // Now, fetch the user by UID
          User? user = await FirebaseAuth.instance.userChanges().firstWhere(
                (user) => user?.uid == uid,
                orElse: () => null,
              );

          return user;
        } else {
          return null;
        }
      }
    } catch (e) {
      print("Error getting user by student UID: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef1 = FirebaseDatabase.instance
          .reference()
          .child('Student')
          .child(user!.uid)
          .child('Student Info')
          .child(user!.uid);
    }
    fetchUserDetails();
    getReferData();
  }

  Future<void> fetchUserDetails() async {
    User? user = await getUserByStudentUid("OsvacXGEXUTgs7HEkA1Xoyy8bqu2");

    if (user != null) {
      print("User Found.");

      userRef2 = FirebaseDatabase.instance
          .reference()
          .child('Student')
          .child(user.uid)
          .child('Student Info')
          .child(user.uid);
    } else {
      print("User not found or error occurred.");
    }

    DataSnapshot snapshot = await userRef2.child('points').get();
    dynamic pointsData = snapshot.value;
    if (pointsData != null) {
      setState(() {
        pointsController.text = pointsData.toString();
      });
    }
  }

  void getReferData() async {
    DataSnapshot snapshot2 = await userRef1.child('referTime').get();
    dynamic referData = snapshot2.value;
    referTime = referData;
  }

  void incrementPoints() async {
    int oldPoints = int.parse(pointsController.text);
    if (referTime < 1) {
      // Increment by 1
      int newPoints = oldPoints + 3;

      // Write the updated value back to the database
      userRef2.child('points').set(newPoints).then((_) {
        // Success callback
        print('Points updated successfully!');
      }).catchError((error) {
        // Error callback
        print('Error updating points: $error');
      });

      referTime++;
      userRef1.child('referTime').set(referTime).then((_) {
        // Success callback
        print('referTime updated successfully!');
      }).catchError((error) {
        // Error callback
        print('Error updating referTime: $error');
      });
    }
  }

  void navigateNextPage(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return InviteFriends();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              width: 390,
              height: 777,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Color(0xFFE5FFFC)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 390,
                      height: 50,
                      decoration: BoxDecoration(color: Color(0xFF9ADBBF)),
                    ),
                  ),
                  Positioned(
                    left: -2,
                    top: 590,
                    child: Container(
                      width: 392,
                      height: 260,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 392,
                              height: 260,
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                          ),
                          Positioned(
                            left: 20.91,
                            top: 120,
                            child: Container(
                              width: 350.19,
                              height: 41.49,
                              decoration: ShapeDecoration(
                                color: Color(0xFF22BAB8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 144.26,
                            top: 130,
                            child: SizedBox(
                              width: 105.58,
                              height: 19.36,
                              child: TextButton(
                                onPressed: () {
                                  incrementPoints();
                                  // Show a Dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Invite code recorded!'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  'Confirm',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppin',
                                    fontWeight: FontWeight.bold,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   left: 20.91,
                          //   top: 43.33,
                          //   child: SizedBox(
                          //     width: 187.11,
                          //     height: 19.36,
                          //     child: Text(
                          //       'Enter the Invite Code',
                          //       style: TextStyle(
                          //         color: Color(0xFF242E42),
                          //         fontSize: 17,
                          //         fontFamily: 'Space Grotesk',
                          //         fontWeight: FontWeight.w300,
                          //         height: 0,
                          //         letterSpacing: 0.41,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          CupertinoTextField(
                            placeholder: 'Enter Invite Code',
                            controller: inviteCodeController,
                            keyboardType: TextInputType.text,
                            obscureText:
                                false, // Set to true if it's a password
                            padding: EdgeInsets.all(25.0),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0.31,
                    top: 89,
                    child: Container(
                      width: 389.69,
                      height: 501,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 389.69,
                              height: 501,
                              decoration:
                                  BoxDecoration(color: Color(0xFFF1BA4E)),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 389.69,
                              height: 501,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 389.69,
                                      height: 501,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFE5FFFC)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16.69,
                            top: 320,
                            child: SizedBox(
                              width: 352.28,
                              height: 65.70,
                              child: Text(
                                'Refer Friends\nto help them get more points!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF22BAB8),
                                  fontSize: 22,
                                  fontFamily: 'Space Grotesk',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 125,
                    top: 11,
                    child: Text(
                      'Refer Friends',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Space Grotesk',
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        navigateNextPage(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Transform.rotate(
                          angle: -1.57,
                          child: Icon(
                            Icons.arrow_upward,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    top: 100,
                    child: Container(
                      width: 310,
                      height: 285,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage("lib/assets/images/reward/invite.jpg"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
