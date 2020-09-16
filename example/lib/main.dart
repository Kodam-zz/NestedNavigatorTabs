import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nested_navigator_tabs/nested_navigator_tabs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nested Navigator Tab"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.red,
              child: Text("Simple"),
              onPressed: () {
                Navigator.of(context).pushNamed("simple");
              },
            ),
            MaterialButton(
              color: Colors.red,
              child: Text("Advanced"),
              onPressed: () {
                Navigator.of(context).pushNamed("advanced");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TabPage extends StatelessWidget {
  const TabPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedNavigatorTabs(
      generator: generateRoute,
      tabs: [
        NavigatorTab(
            defaultRouteName: "page1",
            navItem: BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                activeIcon: Icon(Icons.mail),
                title: Text("Mail"))),
        NavigatorTab(
            defaultRouteName: "page2",
            navItem: BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                title: Text("Person"))),
      ],
    );
  }
}

class AdvancedTabPage extends StatelessWidget {
  const AdvancedTabPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedNavigatorTabs(
      initialTab: 1,
      generator: generateRoute,
      tabs: [
        NavigatorTab(
            defaultRouteName: "page1",
            navItem: BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                activeIcon: Icon(Icons.mail),
                title: Text("Mail"))),
        NavigatorTab(
            defaultRouteName: "page2",
            navItem: BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                title: Text("Person"))),
      ],
      bottomBarBuilder: (context, navItems, selectedIndex, onIndexSelected) =>
          CupertinoTabBar(
        items: navItems,
        onTap: onIndexSelected,
        currentIndex: selectedIndex,
      ),
      layoutBuilder: (context, container, bottomBar, currentIndex) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Text(
                "Custom layout with custom BottomNavigationBar",
                textAlign: TextAlign.center,
              ),
              bottomBar,
              Expanded(
                child: container,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPage extends StatelessWidget {
  final String title;
  final String to;

  const CustomPage({Key key, @required this.title, this.to}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nested Navigator Tab"),
      ),
      body: Builder(builder: (context) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20),
              ),
              MaterialButton(
                color: Colors.red,
                child: Text("next page"),
                onPressed: to != null
                    ? () {
                        Navigator.of(context).pushNamed(to);
                      }
                    : null,
              ),
              MaterialButton(
                color: Colors.red,
                child: Text("Root navigator"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamed("page3");
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: Colors.red,
                    child: Text("Mail tab"),
                    onPressed: () {
                      try {
                        NestedNavigatorTabs.switchTabTo(context, tabIndex: 0);
                      } catch (exception) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("No tabbar found"),
                        ));
                      }
                    },
                  ),
                  MaterialButton(
                    color: Colors.red,
                    child: Text("Person tab"),
                    onPressed: () {
                      try {
                        NestedNavigatorTabs.switchTabTo(context, tabIndex: 1);
                      } catch (exception) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("No tabbar found"),
                        ));
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => DemoPage());
    case 'simple':
      return MaterialPageRoute(builder: (_) => TabPage());
    case 'advanced':
      return MaterialPageRoute(builder: (_) => AdvancedTabPage());
    case 'page1':
      return MaterialPageRoute(
          builder: (_) => CustomPage(
                title: "page1",
                to: "page3",
              ));
    case 'page2':
      return MaterialPageRoute(
          builder: (_) => CustomPage(
                title: "page2",
                to: "page3",
              ));
    case 'page3':
      return MaterialPageRoute(
          builder: (_) => CustomPage(
                title: "page3",
                to: "page4",
              ));
    case 'page4':
      return CupertinoPageRoute(
          builder: (_) => CustomPage(title: "page4 - cupertino"));
    default:
      return MaterialPageRoute(builder: (_) => CustomPage(title: "default"));
  }
}
