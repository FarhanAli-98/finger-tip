import 'dart:collection';


import 'package:ball_on_a_budget_planner/helpers/styles_custom.dart';
import 'package:ball_on_a_budget_planner/widgets/card_expense_month.dart';
import 'package:ball_on_a_budget_planner/widgets/chart_categories_list.dart';
import 'package:ball_on_a_budget_planner/widgets/circularPieChart.dart';
import 'package:ball_on_a_budget_planner/widgets/line_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:easy_localization/easy_localization.dart';

import '../helpers/utils.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/income.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  
  String tabMonth, monthLabel;
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  Stream<QuerySnapshot> query;
  Stream<QuerySnapshot> query2;

  List<Expense> expenses;
  List<Income> incomes;
  int month;

  String userid;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
     setUserid();

    DateTime now = DateTime.now();
     tabMonth = '${now.month.toString()}${now.year.toString()}';
    
     monthLabel = '${labelMonth(tabMonth.substring(0,3))}'+' ${now.year.toString()}';
    month = now.month;
 
   

    print(userid);
  }

  void setUserid()async{
     userid = await storage.read(key: 'userId');
   print(userid);
   
   setState(() {
     
   });
  }

  @override
  Widget build(BuildContext context) {
   print(tabMonth);
    return Scaffold(
    
      body:CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              
              Column(
                children: [
                  SizedBox(height: 10,),
                  Text( monthLabel , 
                    style: customStyleLetterSpace(Colors.white, 20, FontWeight.w800,0.338)),
                  SizedBox(height: 10,),
                  StreamBuilder(
                    stream: query =  FirebaseFirestore.instance
                          .collection('users')
                          .doc(userid)
                          .collection('incomes')
                          .where('tabMonth', isEqualTo: tabMonth )
                          //.orderBy('day')
                          .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data){
                            if (data.connectionState == ConnectionState.active) {
                              if (data.connectionState == ConnectionState.active) {
                                incomes = data.data.docs.map((data) => Income.fromMap(data.data())).toList();
                                print(incomes);
                                double monthIncome = incomes.map((inco) => inco.income).fold(0.0, (a, b) => a + b);
                                print(monthIncome);
                                return Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: _overviewExpenses(monthIncome, 'income_month_total'.tr(), Colors.green)
                                );
                              }

                            }else{
                              return Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: _overviewExpenses(0, 'income_month_total'.tr(), Colors.green)
                            );

                            }

                          
                            return Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: _overviewExpenses(0, 'income_month_total'.tr(), Colors.green)
                            );
                            
                          }
                  ),
            
                  StreamBuilder(
                    stream: query =  FirebaseFirestore.instance
                          .collection('users')
                          .doc(userid)
                          .collection('expenses')
                          .where('tabMonthExp', isEqualTo: tabMonth )
                          .orderBy('day')
                          .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data){
                      if (data.connectionState == ConnectionState.active) {
                        if (data.data.docs.length > 0  ){
                          expenses = data.data.docs.map((data) => Expense.fromMap(data.data())).toList();
                          double monthChange = expenses.map((exp) => exp.value).fold(0.0, (a, b) => a + b);
                          dynamic days = daysInMonth(month);
                           List<double> perDay = List.generate(days, (int index) {
                            return expenses.where((exp) => exp.day == (index + 1))
                                .map((exp) => exp.value)
                                .fold(0.0, (a, b) => a + b);
                          });

                          List<String> creditCards = [];
                          expenses.forEach((e) { 
                            if(!creditCards.contains(e.budget)){
                              creditCards.add(e.budget);
                            }
                          });
                          
                          List<Map> cardsExpensed = [];
                          for (var i = 0; i < creditCards.length; i++) {
                            Map<String, dynamic> map = new HashMap();
                            double expend;
                            double total = 0;
                            map['bank'] = creditCards[i];
                            
                            expenses.forEach((e) { 
                              if(e.budget == creditCards[i]){
                                expend = e.value;
                                total  = expend + total;
                              }

                            });
                            map['expend'] = total;
                            cardsExpensed.add(map);
                          }
                        
           
                          List<Map> chartDataList = [];
                          for (var i = 0; i < expenses.length; i++) {
                            Map<String, dynamic> map = new HashMap();
                            map['expend'] = expenses[i].value.toString();
                            map['transaction'] = expenses[i].dateCreate;
                            map['place'] = expenses[i].place;
                            map['category'] = Category(
                              timestamp: expenses[i].category,
                              categoryName: expenses[i].category,
                              color: expenses[i].categoryColor,
                              icon: expenses[i].categoryIcon,

                            );
                            chartDataList.add(map);
                          }

                           return Column(
                            children: [
                              
                              Container(padding: EdgeInsets.only(left: 15, right: 15),
                              child: _overviewExpenses(monthChange, 'montly_expense'.tr(), Colors.red)),
                              Container(
                                padding: EdgeInsets.only(left: 10,  right: 10),
                                child: Card(
                                  color: Colors.black,
                                  shape:RoundedRectangleBorder( borderRadius: BorderRadius.circular(20.0),),
                                  elevation: 10.0,
                                  child: CardExpenseMonth(cardExpnses:cardsExpensed ,),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15,  right: 15),
                                child: LineChartPage(data: perDay, max: monthChange +1000,)
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 10, left:10, top: 5),
                                child: Card(
                                  color: Colors.black,
                                  shape:RoundedRectangleBorder( borderRadius: BorderRadius.circular(20.0),),
                                  elevation: 10.0,
                                  child: Column(
                                    children: [
                                      CircularPieChart(chartDataList),
                                      ChartCategoriesList(categoriesList: chartDataList)
                                    ],
                                  )
                                )
                              )

                            ],
                          );
                        }else{
                          return  Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child:  Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    
                                    _overviewExpenses(0, 'montly_expense'.tr(), Colors.red),
                                    SizedBox(height: 20,),
                                    Image.asset('assets/images/no_data2.png'),
                                    SizedBox(height: 30),
                                    Text(
                                       'no_expenses'.tr() + " $monthLabel",
                                      style: customStyle(Colors.white, 16, FontWeight.bold)
                                    ),
                                    SizedBox(height: 10),
                                  ],
                              ),
                            
                          );

                        }
                      }
                      return Column(
                        children: [
                          
                          Container(padding: EdgeInsets.only(left: 15, right: 15),
                            child: _overviewExpenses(0, 'montly_expense'.tr(), Colors.red)),
                          SizedBox(height: 150,),
                          
                          Image.asset('assets/images/no_data2.png'),
                                    SizedBox(height: 30),
                                    Text(
                                       'no_expenses'.tr() + " $monthLabel",
                                      style: customStyle(Colors.white, 16, FontWeight.bold)
                                    ),
                                    SizedBox(height: 10),
                        ],
                      );
                    },
                  )
                
                  ,
                ],
              ),

             
            ])
          )
        ]
      ),
      
    );
  }

   Widget _overviewExpenses(double amount, String title, Color colorMoney){
    return Container(
      
      child: Card(
        color: Colors.black,
        shape:RoundedRectangleBorder( borderRadius: BorderRadius.circular(20.0),),
        elevation: 10.0,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
             
              Center(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        title,
                        style: customStyle(Colors.white, 14, FontWeight.normal)
                      ),
                    ),
                    Center(
                      child: Text(
                        "  \$${oCcy.format(amount)}",
                         style: customStyle(colorMoney, 14, FontWeight.bold)
                         
                       
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}