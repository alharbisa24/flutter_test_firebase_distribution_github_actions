import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mltqa/main.dart';
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body:  Center(
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
                child: Icon(Icons.app_registration_rounded, color: Colors.blue[900],),
              ),
              
              const SizedBox(height: 30),

              Text("Register", style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
              ),



              Form(
                key: formstate,
                child: Column(
                  children: [
  Text("Register To Continue Using The App"),
              const SizedBox(height: 30),
                TextFormField(
                  controller: email,
                  validator: (val){
                    if(val == ''){
                      return 'please enter an email';
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
              const SizedBox(height: 20),
              TextFormField(
                controller: password,
                obscureText: true,
                validator: (val){
                    if(val == ''){
                      return 'please enter password';
                    }else if(val != confirm_password.text){
                      return 'Sorry ! passwords not equals';

                    }
                  },
 decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '**********',
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
                  prefixIcon: const Icon(Icons.key),
                  prefixIconColor: Colors.blue,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              
 ),
              ),
              const SizedBox(height: 20),

                 TextFormField(
                controller: confirm_password,
                obscureText: true,
                validator: (val){
                    if(val == ''){
                      return 'please enter confirm password';
                    }else if(val != password.text){
                      return 'Sorry ! passwords not equals';

                    }
                  },
 decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: '**********',
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
                  prefixIcon: const Icon(Icons.key),
                  prefixIconColor: Colors.blue,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              
 ),
              ),
              const SizedBox(height: 30),
                SizedBox(
                width: double.infinity, 
                child: MaterialButton(
                  onPressed: () async {
                    if(formstate.currentState!.validate()){
                  try {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email.text,
    password: password.text,
  );
    if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage())
                  );
                }
} on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed. Please try again.';

  if (e.code == 'weak-password') {
     errorMessage = 'The password provided is too weak.';

  } else if (e.code == 'email-already-in-use') {
         errorMessage = 'The account already exists for that email.';

  }
     if (context.mounted) {
                     AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'Error',
                      desc:
                          errorMessage,
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red,
                    ).show();
                  
                      }
} catch (e) {
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
                  child: const Text('Register', style: TextStyle(color: Colors.white)),
                ),
                ),
                SizedBox(height: 20),
                  ],
                )),
            
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    
    );
  }
}