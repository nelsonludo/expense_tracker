// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';
import './widgets/chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          appBarTheme: AppBarTheme(
              toolbarTextStyle: ThemeData.light()
                  .textTheme
                  .copyWith(
                      titleLarge: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                  ))
                  .bodyMedium,
              titleTextStyle: ThemeData.light()
                  .textTheme
                  .copyWith(
                      titleLarge: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold))
                  .titleLarge),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(error: Colors.red)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // String titleInput = '';

  final List<Transaction> _userTransactions = [];

  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  void _addTransaction(String txTitle, double txAmount, DateTime choseDate) {
    final newTx = Transaction(
        id: DateTime.now().toString(),
        title: txTitle,
        amount: txAmount,
        date: choseDate);

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(ctx).size.width * 0.8,
                  height: MediaQuery.of(ctx).size.height * 0.6,
                  child: NewTransaction(addTransaction: _addTransaction)),
            ],
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(
      Function chartBarWidget, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Show Chart'),
          Switch.adaptive(
            value: _showChart,
            onChanged: (value) {
              setState(() {
                _showChart = value;
              });
            },
          ),
        ],
      ),
      _showChart ? chartBarWidget(0.7) : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
      Function chartBarWidget, Widget txListWidget) {
    return [chartBarWidget(0.3), txListWidget];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    final appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Expense Tracker'),
      actions: <Widget>[
        IconButton(
            onPressed: () => _startAddNewTransaction(context),
            icon: const Icon(Icons.add))
      ],
    );

    final txListWidget = SizedBox(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: Expanded(
        child: TransactionList(
            userTransactions: _userTransactions,
            deleteTransaction: _deleteTransaction),
      ),
    );

    chartBarWidget(height) => SizedBox(
          height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
              height,
          child: Chart(
            recentTransactions: _recentTransactions,
          ),
        );

    return Scaffold(
      appBar: appBar,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (isLandScape)
            ..._buildLandscapeContent(chartBarWidget, txListWidget),
          if (!isLandScape)
            ..._buildPortraitContent(chartBarWidget, txListWidget),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }
}
