import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_hive/domain/models/user_model.dart';
import 'package:find_hive/ui/pages/detection/domain/entities/camera_data.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:find_hive/data/constants/categories.dart';
import 'package:find_hive/domain/models/found_item.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import '../../data/constants/colors.dart';

class ReportItemsPage extends StatefulWidget {
  const ReportItemsPage({super.key});

  @override
  State<ReportItemsPage> createState() => _ReportItemsPageState();
}

class _ReportItemsPageState extends State<ReportItemsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final categoriesList = [
    Category.accessories,
    Category.belongings,
    Category.documents,
    Category.electronics,
  ];
  String _category = Category.documents;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ModalRoute.of(context)!.settings.arguments as CameraData?;
      if (data != null) {
        setState(() {
          _nameController.text = data.suggestionName;
          _descriptionController.text = data.suggestionName;
          _image = data.cameraImage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully Captured Image')),
        );
      }
    });
  }

  Future<Map?> _uploadImageToImgBB(File image) async {
    const String apiKey = 'ae1b6fde2eb30acbe0ce3b1964deb9e0';
    final url = Uri.parse(
      'https://api.imgbb.com/1/upload?expiration=5356800&key=$apiKey',
    );

    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success']) {
        print(
          'Image uploaded to ImgBB: ${jsonResponse['data']['display_url']}',
        );
        return {
          'url': jsonResponse['data']['display_url'],
          'delete_url': jsonResponse['data']['delete_url'],
        };
      } else {
        throw Exception(
          'ImgBB upload failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      return null;
    }
  }

  Future<void> createChannel({
    required String channelID,
    required String ownerId,
  }) async {
    final client = StreamChatClient('7m3ztxqnkpxn', logLevel: Level.INFO);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not signed in');
    }

    final chatUser = User(
      id: user.uid,
      extraData: {
        'name': user.displayName ?? 'Unknown',
        'image': user.photoURL ?? 'https://i.imgur.com/fR9Jz14.png',
      },
    );

    try {
      await client.connectUser(chatUser, client.devToken(user.uid).rawValue);
      final channel = client.channel('messaging', id: channelID);
      await channel.create();
      await channel.watch();
      await channel.addMembers([user.uid]);
      await client.disconnectUser();
    } catch (e) {
      print('Error creating channel: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create channel: $e')));
      rethrow;
    }
  }

  Future<void> _uploadReportedItem() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Please sign in to report an item');
        }

        // Upload image to ImgBB
        final imageUrl = await _uploadImageToImgBB(_image!);
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }

        final userDetail = await UserModel.getUserDetails();
        final itemId = FirebaseFirestore.instance.collection('items').doc().id;

        // Create ReportedItem
        final item = ReportedItem(
          id: userDetail?.regNo ?? 'BU20CSC****',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          location: _locationController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          firestoreID: itemId,
          imagePath: imageUrl['url'],
          deleteUrl: imageUrl['delete_url'],
          createdAt: Timestamp.now(),
          isFound: false,
          personName: userDetail?.name ?? 'Unknown',
        );

        // Save to Firestore
        await item.uploadReportedItem();

        // Create Stream Chat channel
        await createChannel(channelID: itemId, ownerId: user.uid);

        // Clear form
        setState(() {
          _nameController.clear();
          _descriptionController.clear();
          _locationController.clear();
          _phoneController.clear();
          _category = Category.documents;
          _image = null;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item reported and chat channel created'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to report item please check internet connection',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and select an image'),
        ),
      );
    }
  }

  Future<void> _openImagePicker() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colours.blue,
      appBar: AppBar(
        backgroundColor: Colours.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Report an Item',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        verticalSpacer(spacing: 25),

                        TextForm(
                          header: 'Name',
                          controller: _nameController,
                          hint: 'Iphone 15pro',
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter item name'
                                      : null,
                        ),
                        verticalSpacer(spacing: 15),
                        TextForm(
                          header: 'Description',
                          controller: _descriptionController,
                          minLines: 2,
                          hint:
                              'Black phone with a sticker of Goku on the back',
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter description'
                                      : null,
                        ),
                        verticalSpacer(spacing: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(color: Colors.white),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    categoriesList.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: ElevatedButton(
                                          onPressed:
                                              () => setState(
                                                () => _category = item,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _category == item
                                                    ? Colors.white
                                                    : Colors.grey[300],
                                            foregroundColor: Colors.black,
                                          ),
                                          child: Text(item),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacer(spacing: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/camera',
                                );
                              },
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            IconButton(
                              onPressed: _openImagePicker,
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                        verticalSpacer(spacing: 40),

                        // Image display
                        if (_image != null)
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('No image selected'),
                            ),
                          ),
                        verticalSpacer(spacing: 20),
                        //TODO image here
                        verticalSpacer(spacing: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _uploadReportedItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colours.blue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                        verticalSpacer(spacing: 20),
                        const Column(
                          children: [
                            Divider(color: Colors.white),
                            Text(
                              'By default the app uses your current location as the location of the reported item',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class TextForm extends StatelessWidget {
  final String header;
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final String? Function(String?)? validator;

  const TextForm({
    super.key,
    required this.header,
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(header, style: const TextStyle(color: Colors.white, fontSize: 15)),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
          ),
          minLines: minLines,
          maxLines: minLines + 1,
          validator: validator,
        ),
      ],
    );
  }
}
