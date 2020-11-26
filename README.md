# Nested navigator tabs

Easy to use and highly configurable nested navigator with named routes and custom BottomBar support.
It is not limited to MaterialPageRoute and you are not forced to use the default BottomNavigationBar.

#### **Route aware events for the tabs**
The multiple navigation stack is implemented by using Navigators inside an IndexedStack. Only the selected tab's navigator is visible but all of them are active, so implementing a route observer won't work for tracking tabs. To overcome this, a fake(empty) page is pushed to the not visible navigators and popped on the active one. When the main tab page isn't visible the empty route is pushed to all of the inner stacks.

## Getting Started
```
dependencies:
  nested_navigator_tabs: ^0.2.0

```
# Usage
For basic usage you have to specify the ***tabs*** and the ***generator*** ([Routes.generateRoute()](https://github.com/n0vah/nested_navigators/blob/master/example/lib/routes.dart)) method:
```dart
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
```
For proper route detection (Route aware events) inside the tabs, a route observer of the root navigator is needed. You have to create a RouteObserver<PageRoute> and register as a navigatorObserver. Then use the RouteObserverProvider widget to make it accessible through the Context.
```dart
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
      builder: (context, child) => RouteObserverProvider(routeObserver: routeObserver, child: child,),
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}
```
The route observer can be obtained through the context by calling: 
```dart
    RouteObserver<PageRoute> routeObserver = RouteObserverProvider.of(context).routeObserver;
```

To track the visibility of a page, there is a VisibilityObserver widget:
```dart
VisibilityObserver(
    onVisible: (fromPop) {
        //fromPop is false if this page was pushed
    },
    onInvisible: (isPopped) {
      // true if the back has been pressed and the page is being popped and false if a new route has been pushed over this
    },
    child:...
)
```



## Other properties

#### **clearStackOnDoubleTap**

Clears the current navigator if you tap on the selected tab(default: true)

#### **popNestedRouteOnBack**

Automatically handles the back events and pops the current nested route(default: true)

#### **initialTab**
Defines the default tab(default: 0)

#### **backMode**
Defines the backstack strategy and switches between the tabs according to it.
 * **stayOnTab**: never switches tabs
 * **switchTabWhenEmpty**: switches to the previously visited tab when the current navigator's stack is empty
 * **globalStack**: goes back and switches between the tabs as they were visited.

#### **onGlobalStackChanged**
Get notified when the current tab or any route changes
```dart
void Function({@required int tab, @required String routeName, @required StackEvent type}) onGlobalStackChanged;
```



## Advanced usage
#### **bottomBarBuilder**
You can specify your own bottom bar instead of the default BottomNavigationBar:
```dart
 Widget Function(
      BuildContext context,
      List<BottomNavigationBarItem> navItems,
      int selectedIndex,
      Function(int) onIndexSelected) bottomBarBuilder;
```
### layoutBuilder

It is possible to re-implement the whole layout including the Scaffold. 
```dart
Widget Function(BuildContext context, IndexedStack container,
      Widget bottomBar, int currentIndex) layoutBuilder;
```
The ***container*** holds the nested Navigators.
The ***bottomBar*** is the widget built by the **bottomBarBuilder**.

## Static methods
```dart
NestedNavigatorTabs.of(BuildContext context, bool isNullOk)
```
You can access to the whole navigator state. If no state found in the provided context it can return null or throw and exception.
```dart
NestedNavigatorTabs.switchTabTo(BuildContext context,int tabIndex)
```

Selects the tab with the given index.
```dart
NestedNavigatorTabs.navigateTo(BuildContext context,int tabIndex, Route route)
```

You can push any kind of route to the **tabIndex** tab (or to the current tab if null) 
```dart
NestedNavigatorTabs.tabNavigatorOf(BuildContext context,int tabIndex, bool setToCurrent)
```
Gets the nested Navigator of the ***tabIndex*** tab and switches to that tab if setToCurrent is true

```dart
NestedNavigatorTabs.back(BuildContext context)
```
Use this instead of Navigator.of(context).back() when you want to follow the globalStack navigation. (For example when a page from the first tab is pushed to the second tab, the Navigator's back just pops the new page but doesn't switch back to the first tab.)
