import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    // Request permission
    if (await Permission.contacts.request().isGranted) {
      // Fetch contacts with name and photo
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() {
        _contacts = contacts;
      });
    } else {
      // Handle permission denial
      openAppSettings(); // Optional: prompt user to open settings
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _contacts != null
          ? ListView.builder(
              itemCount: _contacts!.length,
              itemBuilder: (context, index) {
                final contact = _contacts![index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: contact.photo != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.photo!),
                        )
                      : CircleAvatar(
                          child: Text(contact.displayName.isNotEmpty
                              ? contact.displayName[0]
                              : '?'),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                  title: Text(contact.displayName),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
