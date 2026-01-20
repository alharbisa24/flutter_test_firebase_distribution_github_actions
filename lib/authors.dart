import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Authors extends StatefulWidget {
  final String docid;
  const Authors({super.key, required this.docid});

  @override
  State<Authors> createState() => _AuthorsState();
}




class _AuthorsState extends State<Authors> {
  bool loading = true;
  List<QueryDocumentSnapshot> authors = [];
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();

  getData() async{
   QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('books').doc(widget.docid).collection("authors").get();
   setState(() {
        authors.clear();
        authors.addAll(querySnapshot.docs);
        loading=false;

   });
  }

  @override
  void initState(){
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addAuthor() {
    if (_formKey.currentState!.validate()) {
      addAuthor();
      getData();
     
    }
  }

  

    Future<void> addAuthor() {
      CollectionReference booksCollection = FirebaseFirestore.instance.collection('books').doc(widget.docid).collection("authors");
      return booksCollection
          .add({
            'fullname': _fullnameController.text, 
            'email': _emailController.text,

          })
          .then((value) => {
                AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'Error',
                      desc:
                        "Author added successfully !",
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
        title: const Text("Authors page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _fullnameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a full name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addAuthor,
                    child: const Text('Add Author'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Authors List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: loading ? Text("loading...")
                  :
                   ListView.builder(
                      itemCount: authors.length,
                      itemBuilder: (context, index) {
                        final author = authors[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(author['fullname']),
                            subtitle: Text(
                              '${author['email']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                   Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => EditAuthor(bookDocId: widget.docid, author: author, ),
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
                                      title: 'Delete Author',
                                      desc: 'Are you sure you want to delete this Author?',
                                      btnOkOnPress: () async {
                                        setState(() => loading = true);
                                        await FirebaseFirestore.instance
                                            .collection("books")
                                            .doc(widget.docid)
                                            .collection("authors")
                                            .doc(author.id)
                                            .delete();
                                        getData();
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class EditAuthor extends StatefulWidget {
  final QueryDocumentSnapshot author;
  final String bookDocId;
  const EditAuthor({super.key, required this.bookDocId ,required this.author });

  @override
  State<EditAuthor> createState() => _EditAuthorState();
}

class _EditAuthorState extends State<EditAuthor> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();


void _editAuthor() async {
  if (_formKey.currentState!.validate()) {
    CollectionReference authorsCollection = FirebaseFirestore.instance.collection('books').doc(widget.bookDocId).collection("authors");

    try {
      await authorsCollection.doc(widget.author.id).update({
            'fullname': _fullnameController.text, 
            'email': _emailController.text,
      });

      if (!mounted) return; 

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        title: 'Success',
        desc: "Author updated successfully!",
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
    _fullnameController.text = widget.author['fullname'];
    _emailController.text = widget.author['email'];
    
   
    
    super.initState();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Author"),
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
                    controller: _fullnameController,
                    decoration: const InputDecoration(labelText: 'full name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a full name';
                      }
                      return null;
                    },
                  ),
   
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (){
                      _editAuthor();
                    },
                    child: const Text('Edit Author'),
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