import 'package:Sandesh/views/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Sandesh/helper/constants.dart';
import 'package:Sandesh/services/database.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:Sandesh/views/videoPlayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  final String? userName;
  final String? chatRoomId;
  final List? usersId;
  ChatScreen({Key? key, @required this.userName, this.chatRoomId, this.usersId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ScrollController _scrollController =
  //     new ScrollController(); // set controller on scrolling
  // bool _show = false;
  // String date = "today";
  bool isLoading = false;
  final db = FirebaseFirestore.instance;
  CollectionReference? chatReference;
  QuerySnapshot? receiverSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;

  String readDate(String time, String date) {
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    // String formattedTime = DateFormat('hh:mm:a').format(now);
    String formattedDate = formatter.format(now);
    if (formattedDate == date) {
      date = "Today";
      return date + " " + time;
    } else {
      return date + " " + time;
    }
  }

  getReceiverDetails() async {
    setState(() {
      isLoading = true;
    });
    List? usersId = widget.usersId;
    String receiverUserId = '';
    for (int i = 0; i < usersId!.length; i++) {
      if (usersId[i] != Constants.myDocId) {
        receiverUserId = usersId[i];
      }
    }

    if (receiverUserId.isNotEmpty) {
      // Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
      await databaseMethods.getReceiverData(receiverUserId).then((result) {
        receiverSnapshot = result;
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Optionally handle the error case here
    }
  }

  @override
  void initState() {
    super.initState();
    // handleScroll();
    // getReceiverDetails();
    chatReference =
        db.collection("ChatRoom").doc(widget.chatRoomId).collection('chats');
  }

  // void showFloationButton() {
  //   setState(() {
  //     _show = true;
  //   });
  // }

  // void hideFloationButton() {
  //   setState(() {
  //     _show = false;
  //   });
  // }

  // _scrollToBottom() {
  //   _scrollController.animateTo(_scrollController.position.minScrollExtent,
  //       duration: Duration(milliseconds: 200), curve: Curves.linear);
  //   setState(() {
  //     _show = false;
  //   });
  // }

  // void handleScroll() async {
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.userScrollDirection ==
  //         ScrollDirection.reverse) {
  //       hideFloationButton();
  //       Fluttertoast.showToast(
  //           msg: date,
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.TOP,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.blueGrey[800],
  //           textColor: Colors.white,
  //           fontSize: 14.0);
  //     }
  //     if (_scrollController.position.userScrollDirection ==
  //         ScrollDirection.forward) {
  //       showFloationButton();
  //     }
  //   });
  // }

  Widget displayData(DocumentSnapshot documentSnapshot) {
    final data =
        documentSnapshot.data() as Map<String, dynamic>?; // Safely cast data
    if (data == null) {
      return const SizedBox.shrink(); // Return empty widget if data is null
    }

    if (data['message'] != null && data['message'] != '') {
      return Text(
        data['message'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else if (data['image'] != null && data['image'] != '') {
      return InkWell(
        child: Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: GestureDetector(
            child: Image.network(
              data['image'],
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(image: data['image']),
                ),
              );
            },
          ),
          height: 200,
          width: 200.0,
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
      );
    } else if (data['video'] != null && data['video'] != '') {
      return GestureDetector(
        child: Image.asset('assets/images/video.png'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPLayer(url: data['video']),
            ),
          );
        },
      );
    } else if (data['file'] != null && data['file'] != '') {
      return GestureDetector(
        child: Image.asset('assets/images/file2_96.png'),
        onTap: () async {
          final url = data['file'];
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error launching file: $e')),
            );
          }
        },
      );
    }
    return const SizedBox.shrink(); // Fallback for no valid content
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    // setState(() {
    //   date = documentSnapshot.data['date'];
    // });
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Container(
              margin: EdgeInsets.fromLTRB(30, 0, 10, 0),
              padding: EdgeInsets.only(top: 5, bottom: 3, left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[800] ?? Colors.green,
                      Colors.green[500] ?? Colors.green
                    ],
                  )),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // new Text(documentSnapshot.data['sendBy'],
                  //     style: new TextStyle(
                  //         fontSize: 14.0,
                  //         color: Colors.black,
                  //         fontWeight: FontWeight.bold)),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: displayData(documentSnapshot),
                  ),
                  new Text(
                    readDate(
                        documentSnapshot.data() != null
                            ? (documentSnapshot.data()
                                as Map<String, dynamic>)['time']
                            : '',
                        documentSnapshot.data() != null
                            ? (documentSnapshot.data()
                                as Map<String, dynamic>)['date']
                            : ''),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                    ),
                  ),
                  // new Icon(
                  //   Icons.check,
                  //   size: 12,
                  //   color: documentSnapshot.data['seen']
                  //       ? Colors.blue
                  //       : Colors.grey,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      // new Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: <Widget>[
      //     new Container(
      //         margin: const EdgeInsets.only(left: 8.0),
      //         child: new CircleAvatar(
      //           backgroundImage:
      //               new NetworkImage(documentSnapshot.data['profile_photo']),
      //         )),
      //   ],
      // ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    // setState(() {
    //   date = documentSnapshot.data['date'];
    // });
    return <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: new CircleAvatar(
                backgroundImage: new NetworkImage((documentSnapshot.data()
                    as Map<String, dynamic>)['profile_photo']),
              )),
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
              padding: EdgeInsets.only(top: 5, bottom: 3, left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange[500] ?? Colors.orange,
                      Colors.orange[800] ?? Colors.orange
                    ],
                  )),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // new Text(documentSnapshot.data['sendBy'],
                  //     style: new TextStyle(
                  //         fontSize: 14.0,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold)),
                  new Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: displayData(documentSnapshot)),
                  new Text(
                    readDate(
                        (documentSnapshot.data()
                            as Map<String, dynamic>)['time'],
                        (documentSnapshot.data()
                            as Map<String, dynamic>)['date']),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs
        .map<Widget>((doc) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: new Row(
                children:
                    (doc.data() as Map<String, dynamic>)['sender_email'] !=
                            Constants.myEmail
                        ? generateReceiverLayout(doc)
                        : generateSenderLayout(doc),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? ''),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      // floatingActionButton: Visibility(
      //     visible: _show,
      //     child: FloatingActionButton(
      //         backgroundColor: Colors.blueGrey[800],
      //         child: Icon(
      //           Icons.arrow_downward,
      //         ),
      //         onPressed: _scrollToBottom)),
      body: Container(
        padding: EdgeInsets.all(0),
        child: new Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: chatReference!
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return new Center(
                    child: Text("Start your chat"),
                  );
                return Expanded(
                  child: new ListView(
                    // controller: _scrollController,
                    reverse: true,
                    children: generateMessages(snapshot),
                  ),
                );
              },
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Colors.green),
              child: _buildTextComposer(),
            ),
            new Builder(builder: (BuildContext context) {
              return new Container(width: 0.0, height: 0.0);
            })
          ],
        ),
      ),
    );
  }

  messageBar() {
    return _isWritting ? getDefaultSendButton() : getDefaultAttachmentButton();
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send, color: Colors.orange),
      onPressed: _isWritting ? () => _sendText(_textController.text) : null,
    );
  }

  pickVideoFromGallery() async {
    Navigator.pop(context);
    FilePickerResult? videoResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        'avi',
        'mov',
        'fly',
        'wmv',
        'm4v',
        'webm',
        'mkv'
      ],
    );
    if (videoResult != null && videoResult.files.single.path != null) {
      File file = File(videoResult.files.single.path!);
      uploadStatusVideo(file);
    }
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'docx',
        'doc',
        'txt',
        'xls',
        'csv',
        'zip',
        'rar',
        'tar'
      ],
    );
    if (fileResult != null && fileResult.files.single.path != null) {
      File file = File(fileResult.files.single.path!);
      uploadStatusFile(file);
    }
  }

  void uploadStatusVideo(file) async {
    if (file != null) {
      String chatroom = widget.chatRoomId!;
      String email = Constants.myEmail;
      int timestamp = new DateTime.now().millisecondsSinceEpoch;
      Reference storageReference = FirebaseStorage.instance.ref().child(
          '$email Storage Data/$chatroom Attachments/video_' +
              timestamp.toString());
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() => null);
      String fileUrl = await storageReference.getDownloadURL();
      saveVideoToDatabase(fileUrl);
    }
  }

  void pickFileFromGallery() async {
    Navigator.pop(context);
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'docx',
        'doc',
        'txt',
        'xls',
        'csv',
        'zip',
        'rar',
        'tar'
      ],
    );
    if (fileResult != null && fileResult.files.single.path != null) {
      File file = File(fileResult.files.single.path!);
      uploadStatusFile(file);
    }
  }

  void uploadStatusFile(file) async {
    if (file != null) {
      String chatroom = widget.chatRoomId!;
      String email = Constants.myEmail;
      int timestamp = new DateTime.now().millisecondsSinceEpoch;
      Reference storageReference = FirebaseStorage.instance.ref().child(
          '$email Storage Data/$chatroom Attachments/file_' +
              timestamp.toString());
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() => null);
      String fileUrl = await storageReference.getDownloadURL();
      saveFileToDatabase(fileUrl);
    }
  }

  attachment(context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Send Attachment",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Send Video ",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: pickVideoFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Send File",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: pickFileFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  IconButton getDefaultAttachmentButton() {
    return new IconButton(
        icon: new Icon(
          Icons.attach_file,
          color: Colors.orange,
        ),
        onPressed: () => attachment(context));
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color:
              _isWritting ? Color(0xff1D3C51) : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.photo_camera, color: Colors.orange),
                    onPressed: () async {
                      String chatroom = widget.chatRoomId!;
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        File image = File(pickedFile.path);
                        String email = Constants.myEmail;
                        int timestamp =
                            new DateTime.now().millisecondsSinceEpoch;
                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child(
                                '$email Storage Data/$chatroom Attachments/img_' +
                                    timestamp.toString() +
                                    '.jpg');
                        UploadTask uploadTask = storageReference.putFile(image);
                        await uploadTask.whenComplete(() => null);
                        String fileUrl =
                            await storageReference.getDownloadURL();
                        _sendImage(messageText: '', imageUrl: fileUrl);
                      }
                    }),
              ),
              new Flexible(
                child: new TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: _textController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isWritting = messageText.length > 0;
                    });
                  },
                  onSubmitted: _sendText,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: messageBar(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText(String text) async {
    _textController.clear();
    List usersId = widget.usersId ?? [];
    String receiverUserId = '';
    for (int i = 0; i < usersId.length; i++) {
      if (usersId[i] != Constants.myDocId) {
        receiverUserId = usersId[i];
      }
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat('hh:mm:a').format(now);
    String formattedDate = formatter.format(now);
    bool seen = false;
    db
        .collection("ChatRoom")
        .doc(widget.chatRoomId)
        .update({"last_msg": text, "timestamp": FieldValue.serverTimestamp()});
    chatReference!.add({
      'message': text,
      "video": '',
      "file": '',
      'sender_email': Constants.myEmail,
      'sendBy': Constants.myName,
      "receiverUserId": receiverUserId,
      'profile_photo': Constants.myProfileImage,
      'image': '',
      'timestamp': FieldValue.serverTimestamp(),
      'timeInNumber': DateTime.now().millisecondsSinceEpoch,
      'time': formattedTime.toString(),
      'date': formattedDate.toString(),
      'seen': seen
    }).then((documentReference) {
      setState(() {
        _isWritting = false;
      });
    }).catchError((e) {});
  }

  void _sendImage({String? messageText, String? imageUrl}) {
    List usersId = widget.usersId ?? [];
    String? receiverUserId;
    for (int i = 0; i < usersId.length; i++) {
      if (usersId[i] != Constants.myDocId) {
        receiverUserId = usersId[i];
      }
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat('hh:mm:a').format(now);
    String formattedDate = formatter.format(now);
    bool seen = false;
    chatReference!.add({
      'message': messageText,
      "video": '',
      "file": '',
      'image': imageUrl,
      'sender_email': Constants.myEmail,
      'sendBy': Constants.myName,
      "receiverUserId": receiverUserId,
      'profile_photo': Constants.myProfileImage,
      'timestamp': FieldValue.serverTimestamp(),
      'timeInNumber': DateTime.now().millisecondsSinceEpoch,
      'time': formattedTime.toString(),
      'date': formattedDate.toString(),
      'seen': seen
    });
  }

  void saveVideoToDatabase(url) {
    List usersId = widget.usersId ?? [];
    String receiveruserId = '';
    for (int i = 0; i < usersId.length; i++) {
      if (usersId[i] != Constants.myDocId) {
        receiveruserId = usersId[i];
      }
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat('hh:mm:a').format(now);
    String formattedDate = formatter.format(now);
    bool seen = false;
    chatReference!.add({
      'message': '',
      "video": url,
      "file": '',
      'sender_email': Constants.myEmail,
      'sendBy': Constants.myName,
      "receiveruserId": receiveruserId,
      'profile_photo': Constants.myProfileImage,
      'image': '',
      'timestamp': FieldValue.serverTimestamp(),
      'timeInNumber': DateTime.now().millisecondsSinceEpoch,
      'time': formattedTime.toString(),
      'date': formattedDate.toString(),
      'seen': seen
    });
  }

  void saveFileToDatabase(url) {
    List usersId = widget.usersId ?? [];
    String receiverUserId = '';
    for (int i = 0; i < usersId.length; i++) {
      if (usersId[i] != Constants.myDocId) {
        receiverUserId = usersId[i];
      }
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat('hh:mm:a').format(now);
    String formattedDate = formatter.format(now);
    bool seen = false;
    chatReference!.add({
      'message': '',
      "video": '',
      "file": url,
      'sender_email': Constants.myEmail,
      'sendBy': Constants.myName,
      "receiverUserId": receiverUserId,
      'profile_photo': Constants.myProfileImage,
      'image': '',
      'timestamp': FieldValue.serverTimestamp(),
      'timeInNumber': DateTime.now().millisecondsSinceEpoch,
      'time': formattedTime.toString(),
      'date': formattedDate.toString(),
      'seen': seen
    });
  }
}

class DetailScreen extends StatelessWidget {
  final String? image;
  DetailScreen({this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              image!,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
