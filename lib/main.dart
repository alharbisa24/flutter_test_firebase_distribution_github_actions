import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mltqa/books.dart';
import 'package:mltqa/register.dart';
import 'package:mltqa/reset_password.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  requestPermissions() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('User granted permission');
} else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  print('User granted provisional permission');
} else {
  print('User declined or has not accepted permission');
}
  }

  
  bool loginStatus = false; 

  @override
  void initState() {
    requestPermissions();
    super.initState(); 
    FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
        setState(() { 
          loginStatus = user != null;
        });
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home Page !"),
            
                  loginStatus ? 
            Column(
              children: [
                Text("Logged in as: ${FirebaseAuth.instance.currentUser?.email ?? ''}"),
                SizedBox(height: 20),

                FirebaseAuth.instance.currentUser!.emailVerified ? 
                Text("email verified !")
                : 
                ElevatedButton(onPressed: (){
                  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                      AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      headerAnimationLoop: false,
                      title: 'email sended',
                      desc:
                          "Check your email inbox !",
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.check,
                      btnOkColor: Colors.blue,
                    ).show();
                }, child: Text("verify my account !"))
                ,
                SizedBox(height: 20),

                ElevatedButton(onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Books()));
                }, child: Text("books page")),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  }, 
                  child: Text("Sign out")
                ),
              ],
            )
            : 
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
              }, 
              child: Text("Login"),
            ),
 
          ],
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
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
                child: Icon(Icons.login, color: Colors.blue[900],),
              ),
              
              const SizedBox(height: 30),

              Text("Login", style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
              ),



              Text("Login To Continue Using The App"),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: password,
                obscureText: true,
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
              const SizedBox(height: 30),
                SizedBox(
                width: double.infinity, 
                child: MaterialButton(
                  onPressed: () async {
                    if(formstate.currentState!.validate()){
                 try {
     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email.text.trim(),
                        password: password.text
                      );
  if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage())
                  );
                }
                      } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed. Please try again.';
      print(e);
                      if (e.code == 'user-not-found') {
                        errorMessage = 'No user found with this email.';

                      } else if (e.code == 'wrong-password') {
                        errorMessage = 'Incorrect password.';
                      } else if (e.code == 'invalid-email') {
                        errorMessage = 'Please enter a valid email address.';
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
                       } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
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
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                          
                ),
                ),
                ],
              )),
              
                SizedBox(height: 20),
                       
              const SizedBox(height: 20),
                   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Forget your password?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetPassword()),
                      );
                    },
                    child: const Text('Reset password', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Register()),
                      );
                    },
                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}