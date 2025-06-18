import 'package:Sandesh/helper/constants.dart';
import 'package:Sandesh/services/database.dart';
import 'package:Sandesh/views/chatScreen.dart';
import 'package:Sandesh/views/messageTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
  bool isLoading = false;
  final TextEditingController searchTextEditingController =
      TextEditingController();
  final DatabaseMethods databaseMethods = DatabaseMethods();
  Stream<QuerySnapshot>? chatStream;

  getChats() async {
    // if (Constants.myUserId.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Error: User ID not found')),
    //   );
    //   return;
    // }
    setState(() {
      isLoading = true;
    });
    try {
      final result = await databaseMethods.getMyAllChats(Constants.myUserId);
      setState(() {
        chatStream = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chats: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  Widget chatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chats'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No chats available'));
        }
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ChatTile(
              usersName: data['usersName'] ?? [],
              usersProfileImage: data['usersProfileImage'] ?? [],
              chatRoomId: data['chatRoomId'] ?? '',
              usersId: data['usersId'] ?? [],
              lastMsg: data['last_msg'] ?? '',
              unseenMsgCount: data['unseen_msg_count'] ?? 0,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatList(),
    );
  }
}
