import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nested_navigator_tabs/nested_navigator_tabs.dart';
import 'package:nested_navigator_tabs/route_observer.dart';

void main() {
  runApp(MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      navigatorObservers: [routeObserver],
      builder: (context, child) => RouteObserverProvider(
        routeObserver: routeObserver,
        child: child,
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

class CustomPage extends StatefulWidget {
  final String title;
  final String to;

  const CustomPage({Key key, @required this.title, this.to}) : super(key: key);

  @override
  _CustomPageState createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  int showCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nested Navigator Tab"),
      ),
      body: VisibilityObserver(
        onVisible: (fromPop) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              showCount++;
            });
          });
        },
        onInvisible: (isPopped) {},
        child: Builder(builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "Visited: $showCount",
                  style: TextStyle(fontSize: 20),
                ),
                MaterialButton(
                  color: Colors.red,
                  child: Text("next page"),
                  onPressed: widget.to != null
                      ? () {
                          Navigator.of(context).pushNamed(widget.to);
                        }
                      : null,
                ),
                MaterialButton(
                  color: Colors.red,
                  child: Text("Root navigator"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed("page3");
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
      ),
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(settings: settings, builder: (_) => DemoPage());
    case 'simple':
      return MaterialPageRoute(settings: settings, builder: (_) => TabPage());
    case 'advanced':
      return MaterialPageRoute(
          settings: settings, builder: (_) => AdvancedTabPage());
    case 'page1':
      return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomPage(
                title: "page1",
                to: "page3",
              ));
    case 'page2':
      return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomPage(
                title: "page2",
                to: "page3",
              ));
    case 'page3':
      return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomPage(
                title: "page3",
                to: "page4",
              ));
    case 'page4':
      return CupertinoPageRoute(
          settings: settings,
          builder: (_) => CustomPage(title: "page4 - cupertino"));
    default:
      return MaterialPageRoute(
          settings: settings, builder: (_) => CustomPage(title: "default"));
  }
}
