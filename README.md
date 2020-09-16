# nested_navigator_tabs

Easy to use and highly configurable nested navigator with named routes and custom BottomBar support.
It is not limited to MaterialPageRoute and you are not forced to use the default BottomNavigationBar.


## Getting Started
```
dependencies:
  nested_navigator_tabs: ^0.1.0

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

## Other properties

#### clearStackOnDoubleTap

Clears the current navigator if you tap on the selected tab(default: true)

#### popNestedRouteOnBack

Automatically handles the back events and pops the current nested route(default: true)

#### initialTab
Defines the default tab(default: 0)

## Advanced usage
#### bottomBarBuilder
You can specify your own bottom bar instead of the default BottomNavigationBar:
```dart
 Widget Function(
      BuildContext context,
      List<BottomNavigationBarItem> navItems,
      int selectedIndex,
      Function(int) onIndexSelected) bottomBarBuilder;
```
#### layoutBuilder

It is possible to re-implement the whole layout including the Scaffold. 
```dart
Widget Function(BuildContext context, IndexedStack container,
      Widget bottomBar, int currentIndex) layoutBuilder;
```
The ***container*** holds the nested Navigators.
The ***bottomBar*** is the widget built by the **bottomBarBuilder**.

## Static methods

#### NestedNavigatorTabs.of(BuildContext context, bool isNullOk)
You can access to the whole navigator state. If no state found in the provided context it can return null or throw and exception.
#### NestedNavigatorTabs.switchTabTo(BuildContext context,int tabIndex)
Selects the tab with the given index.

#### NestedNavigatorTabs.switchTabTo(BuildContext context,int tabIndex, Route route)
You can push any kind of route to the **tabIndex** tab (or to the current tab if null) 
