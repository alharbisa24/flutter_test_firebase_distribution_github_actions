import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
    TextEditingController email = TextEditingController();
  bool isLoading = false;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset password"),
      ),
      body: Column(
        children: [
           Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),

                ),
                child: Icon(Icons.lock_reset, color: Colors.blue[900],),
              ),
              
              const SizedBox(height: 30),

              Text("Reset Password", style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
              ),



              Text("Reset your password To Continue Using The App"),
              Form(
                key: formstate,
                
                child: Column(
                children: [
const SizedBox(height: 30),
                TextFormField(
                  controller: email,
                  validator: (val){
                    if(val == ''){
                      return 'please enter an email !';
                    }
                  },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  prefixIconColor: Colors.blue,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.emailAddress,
                ),              
              const SizedBox(height: 30),
                SizedBox(
                width: double.infinity, 
                child: MaterialButton(
                  onPressed: () async {
                 
                 if(formstate.currentState!.validate()){
                  try{
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'email sended !',
                      desc:
                          "Check your email ..",
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.check,
                      btnOkColor: Colors.blue,
                    ).show();
               
                 }catch(e){
                  if (context.mounted) {
                      AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'Error',
                      desc:
                          'Error: ${e.toString()}',
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red,
                    ).show();
                      
                      }
                 }
                 }
                
                  },
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                  ),
                  color: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
  child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Reset', style: TextStyle(color: Colors.white)),
                          
                ),
                ),
                ],
              )),
              
                SizedBox(height: 20),
            ]
          )
        )
           )
        ],
      ),
    );
  

  }
}