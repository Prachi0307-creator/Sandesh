import 'package:flutter/material.dart';
import 'package:Sandesh/views/chatScreen.dart';
import 'package:Sandesh/helper/constants.dart';

class ChatTile extends StatelessWidget {
  final List usersName;
  final List usersProfileImage;
  final String chatRoomId;
  final List usersId;
  final String lastMsg;
  final int unseenMsgCount;

  const ChatTile({
    Key? key,
    required this.usersName,
    required this.usersProfileImage,
    required this.chatRoomId,
    required this.usersId,
    required this.lastMsg,
    required this.unseenMsgCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the other user's name and profile image (not the current user)
    String displayName = 'Unknown';
    String displayImage = '';

    for (int i = 0; i < usersName.length; i++) {
      if (usersName[i] != Constants.myName && usersName[i] != null) {
        displayName = usersName[i];
        break;
      }
    }

    for (int i = 0; i < usersProfileImage.length; i++) {
      if (usersProfileImage[i] != Constants.myProfileImage &&
          usersProfileImage[i] != null) {
        displayImage = usersProfileImage[i];
        break;
      }
    }

    return Column(
      children: [
        const Divider(height: 10.0),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:
                displayImage.isNotEmpty ? NetworkImage(displayImage) : null,
            onBackgroundImageError:
                displayImage.isNotEmpty ? (error, stackTrace) => null : null,
            child: displayImage.isEmpty
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(
            displayName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              lastMsg.isEmpty ? 'No messages' : lastMsg,
              style: const TextStyle(color: Colors.grey, fontSize: 15.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: unseenMsgCount > 0
              ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Text(
                    '$unseenMsgCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userName: displayName.toUpperCase(),
                  chatRoomId: chatRoomId,
                  usersId: usersId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
