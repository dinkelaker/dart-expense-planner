import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

import './widget/new_transaction.dart';
import './widget/chart.dart';

import './model/transaction.dart';
import 'widget/transaction_list.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Planner',
      theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          accentColor: Colors.green,
          fontFamily: 'OpenSans',
          textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
              )),
          appBarTheme: AppBarTheme(
              textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ))),
      home: MyHomePage(title: 'Expense Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [
    // Transaction(
    //     id: 't1', title: 'New Shoes', amount: 69.99, date: DateTime.now()),
    // Transaction(
    //     id: 't2',
    //     title: 'Weekly Groceries',
    //     amount: 16.53,
    //     date: DateTime.now()),
  ];

  var _nextId = 1;

  void _addTransaction(String title, double amount, DateTime date) {
    var transaction = Transaction(
        id: 't${_nextId++}',
        title: title,
        amount: amount,
        date: date != null ? date : DateTime.now());
    print(
        'New Transacion: id=${transaction.id} title=${transaction.title}, amount=${transaction.amount}');

    setState(() {
      _transactions.add(transaction);
    });
  }

  void _deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    setState(() {});
  }

  void _startAddNewTransaction(BuildContext ctxt) {
    showModalBottomSheet(
        context: ctxt,
        builder: (bCtxt) {
          return NewTransaction(_addTransaction);
        });
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  var _showChart = true;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final appBar = AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        )
      ],
    );

    final heightWorkArea = (MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top);

    final chartSwitchWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Show Chart'),
        Switch(
          value: _showChart,
          onChanged: (val) {
            setState(() {
              _showChart = val;
            });
          },
        )
      ],
    );

    final createResponsiveChartWidget = (heightRatio) => Container(
      height: heightWorkArea * heightRatio,
      width: double.infinity,
      child: Card(
        color: Theme.of(context).primaryColorDark,
        child: Chart(_recentTransactions),
      ),
    );

    final txListWidget = Container(
      height: heightWorkArea * 0.6,
      child: TransactionList(_transactions, _deleteTransaction),
    );

    final scaffold = Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (isLandscape) chartSwitchWidget,
            if (!isLandscape) createResponsiveChartWidget(0.3),
            if (!isLandscape) txListWidget,
            if (isLandscape) _showChart ? createResponsiveChartWidget(0.6) : txListWidget,
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );

    return scaffold;
  }
}
