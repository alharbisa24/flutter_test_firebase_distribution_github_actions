import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mltqa/authors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  State<Books> createState() => _BooksState();
}




class _BooksState extends State<Books> {
  bool loading = true;
  List<QueryDocumentSnapshot> books = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();


  final Stream<QuerySnapshot> _booksStream = FirebaseFirestore.instance.collection('books').snapshots();


  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addBook() {
    if (_formKey.currentState!.validate()) {
      addBook();
     
    }
  }
    File? file;
    String? imageUrl;
  
  getImageGallery() async{
    final ImagePicker picker = ImagePicker();
    final XFile? ImageGallery = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (ImageGallery != null) {
   
      setState(() {
            file = File(ImageGallery.path);

      });


    String imageName = p.basename(ImageGallery.path).replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    var refStorage = FirebaseStorage.instance.ref("images/$imageName");
    await refStorage.putFile(file!);
    imageUrl = await refStorage.getDownloadURL();

 

  } else {
    print("User cancelled camera or no image selected");
  }
  }


  getImageCamera() async{
    final ImagePicker picker = ImagePicker();
    final XFile? imageCamera = await picker.pickImage(source: ImageSource.camera);

     if (imageCamera != null) {
    setState(() {
      file = File(imageCamera.path);
    });
  } else {
    debugPrint("User cancelled camera or no image selected");
  }

  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


      CollectionReference booksCollection = FirebaseFirestore.instance.collection('books');

    Future<void> addBook() {
      return booksCollection
          .add({
            'title': _titleController.text, 
            'description': _descriptionController.text,
            'date': _selectedDate,
            "user_id":FirebaseAuth.instance.currentUser!.uid,
            "image_url": imageUrl ?? 'none'

          })
          .then((value) => {
                AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'Error',
                      desc:
                        "book added successfully !",
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.blue,
                    ).show()
          })
          .catchError((error) => {
             AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'Error',
                      desc:
                        error.toString(),
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red,
                    ).show()
          });
    }

    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books page"),
      ),
      body:
       SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: 
        Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
         
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),

SizedBox(height: 20),
                  ElevatedButton(onPressed: (){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload book image'),
        message: const Text('Choose a way to upload'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () async {
              await getImageGallery();
              Navigator.pop(context);
            },
            child: const Text('From gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              await getImageCamera();
              Navigator.pop(context);
            },
            child: const Text('From Camera'),
          ),

        ],
      ),
    );
                  }, child: Text("choose image")),

        if (imageUrl != null) ...[
  const SizedBox(height: 20),
  const Text("Selected Image:"),
  Image.network(imageUrl!, width: 200),
],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Date: ${_selectedDate.toString().substring(0, 10)}'),
                      IconButton(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBook,
                    child: const Text('Add Book'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Book List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
   StreamBuilder<QuerySnapshot>(
      stream: _booksStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
              shrinkWrap: true,   
      physics: NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                         
                            leading: 
                            data['image_url'] != null ?
                            Image.network(data['image_url'], height: 200)
                            :
                            Text("Image"),
                            
                          
                            title: Text(data['title']),
                            subtitle: Text(
                              '${(data['date'] as Timestamp).toDate().toString().substring(0, 10)}\n${data['description'].length > 50 ? data['description'].substring(0, 50) + '...' : data['description']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  IconButton(
                                  icon: const Icon(Icons.remove_red_eye_sharp, color: Colors.green),
                                  onPressed: () {
                                     Navigator.push(
                                      context, 
                                     MaterialPageRoute(
                                        builder: (context) => Authors(docid: document.id),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                   Navigator.push(
                                      context, 
                                        MaterialPageRoute(
                                        builder: (context) => EditBook(book: document as QueryDocumentSnapshot<Object?>,),
                                      ),
                                    );
                                  },
                                ),
                                
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.rightSlide,
                                      headerAnimationLoop: false,
                                      title: 'Delete Book',
                                      desc: 'Are you sure you want to delete this book?',
                                      btnOkOnPress: () async {
                                       setState(() => loading = true);
                                        await FirebaseFirestore.instance
                                            .collection("books")
                                            .doc(document.id)
                                            .delete();

                                      if (data['image_url'] != null){
                                        FirebaseStorage.instance.refFromURL(data['image_url']).delete();
                                      }
                                      },
                                      btnCancelOnPress: () {},
                                      btnOkIcon: Icons.delete,
                                      btnOkText: "Delete",
                                      btnOkColor: Colors.red,
                                      btnCancelText: "Cancel",
                                    ).show();
                                  },
                                ),
                              ],
                            )
                        ),
                        );
                    
          }).toList(),
        );
      },
    )
  
              

                
            
        
          ],
        ),
      ),
    );
  }
}


class EditBook extends StatefulWidget {
  final QueryDocumentSnapshot book;
  const EditBook({super.key, required this.book });

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
    Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
void _editBook() async {
  if (_formKey.currentState!.validate()) {
    CollectionReference booksCollection = FirebaseFirestore.instance.collection('books');

    try {
      await booksCollection.doc(widget.book.id).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDate,
        "user_id": FirebaseAuth.instance.currentUser!.uid
      });

      if (!mounted) return; // ⬅️ مهم

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        title: 'Success',
        desc: "Book updated successfully!",
        btnOkOnPress: () {},
        btnOkIcon: Icons.check,
        btnOkColor: Colors.blue,
      ).show();
    } catch (error) {
      if (!mounted) return; 

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        title: 'Error',
        desc: error.toString(),
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
    }
  }
}

 
  @override
  void initState() {
    _titleController.text = widget.book['title'];
    _descriptionController.text = widget.book['description'];

    _selectedDate = (widget.book['date'] as Timestamp).toDate();
    
   
    
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit book"),
      ),
      body: 
                Padding(padding: EdgeInsets.all(5), child:   Column(
        children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
   
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Date: ${_selectedDate.toString().substring(0, 10)}'),
                      IconButton(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (){
                      _editBook();
                    },
                    child: const Text('Edit Book'),
                  ),
                ],
              ),
            )
          ]

    )
                )

      );
    
          
        
      
    
  }
}