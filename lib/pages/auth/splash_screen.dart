import 'package:ball_on_a_budget_planner/helpers/styles_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//me
import 'package:ball_on_a_budget_planner/bloc/sign_in_bloc/sign_in_bloc_bloc.dart';
import 'package:ball_on_a_budget_planner/helpers/helpers.dart';
import 'package:ball_on_a_budget_planner/pages/auth/welcome_page.dart';
import 'package:ball_on_a_budget_planner/pages/home_page.dart';
import 'package:ball_on_a_budget_planner/widgets/logo.dart';


class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> with TickerProviderStateMixin{

  AnimationController _controller;
   SignInBloc signInBloc;
  
  
   @override
  void initState() {
    super.initState();

     _controller = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    );
    _controller.forward();
    Future.delayed(Duration(milliseconds: 1700), () {

        signInBloc = BlocProvider.of<SignInBloc>(context);

        signInBloc.listen((state) { 
          print(state);
          if(state is CheckIfSignedInCompletedState ){
            if( state.res ){
              Navigator.pushReplacement(context, navegateFadein(context, HomePage()));
            }else{
              Navigator.pushReplacement(context, navegateFadein(context, WelcomePage()));
            }
          }
          if( state is CheckIfSignedInFailedState){
            print('failed to check if logged in');
            Navigator.pushReplacement(context, navegateFadein(context, WelcomePage()));
          }
        });

        signInBloc.add(CheckIfSignedIn());

       //Navigator.pushReplacement(context, navegateFadein(context, WelcomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, 
      child: Scaffold(
        backgroundColor: Theme.of(context).accentColor,
         body: Container(
           padding: EdgeInsets.only(left: 20, right: 20),
            
           child: Column(
             children: [

               Container(
                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .3),
                 child: Align(
                   alignment: Alignment.center,
                   child: Column(
                     children: [
                       RotationTransition(
                         turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                         child: Center(child: Logo(title: ''))
                        ),
                        SizedBox(height: 5,),
                        Text('Budget Planner 2021', style: customStyle(Colors.white, 25, FontWeight.bold)
                        
                        ,),
                        SizedBox(height: 5,),
                       
                       
                     ],
                   ),
                 )
                )
             ],
           ),
         )
         
      ),
    );
  }

   
}