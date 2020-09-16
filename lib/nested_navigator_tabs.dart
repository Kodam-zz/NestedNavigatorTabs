library nested_navigator_tabbar;

import 'package:flutter/material.dart';

class NestedNavigatorTabs extends StatefulWidget {
  /// List of tabs with the initial route's name
  final List<NavigatorTab> tabs;

  /// Custom builder for the bottom bar
  final Widget Function(
      BuildContext context,
      List<BottomNavigationBarItem> navItems,
      int selectedIndex,
      Function(int) onIndexSelected) bottomBarBuilder;

  /// Custom layout builder
  final Widget Function(BuildContext context, IndexedStack container,
      Widget bottomBar, int currentIndex) layoutBuilder;

  /// Pops the current nested navigator to the initial route when the selected tab is tapped
  final bool clearStackOnDoubleTap;

  ///  Pops the current nested route on back press
  final bool popNestedRouteOnBack;

  ///  Initial tab index, default is 0
  final int initialTab;

  /// Route generator for the named routes
  final Route Function(RouteSettings routeSettings) generator;

  List<String> get _defaultRouteNames =>
      tabs.map((e) => e.defaultRouteName).toList();

  List<BottomNavigationBarItem> get _navItems =>
      tabs.map((e) => e.navItem).toList();

  NestedNavigatorTabs({
    Key key,
    @required this.tabs,
    @required this.generator,
    this.bottomBarBuilder,
    this.layoutBuilder,
    this.clearStackOnDoubleTap = true,
    this.popNestedRouteOnBack = true,
    this.initialTab = 0,
  })  : assert(tabs != null && tabs.isNotEmpty,
            "Tabs must contain at least 1 item"),
        assert(initialTab >= 0 && initialTab < tabs.length),
        assert(generator != null),
        assert(clearStackOnDoubleTap != null),
        assert(popNestedRouteOnBack != null),
        super(key: key);

  @override
  _NestedNavigatorTabsState createState() => _NestedNavigatorTabsState();

  static _NestedNavigatorTabsState of(
    BuildContext context, {
    bool isNullOk = false,
  }) {
    assert(isNullOk != null);
    assert(context != null);
    final _NestedNavigatorTabsState result = context.findAncestorStateOfType();
    if (isNullOk || result != null) {
      return result;
    }
    throw FlutterError(
      'NestedTabNavigator.of() called with a context that does not contain a NestedTabNavigator.\n',
    );
  }

  /// Gets the NavigatorState of the [tabIndex] tab and optionally switches to it.
  static NavigatorState tabNavigatorOf(
    BuildContext context, {
    @required int tabIndex,
    @required bool setToCurrent,
  }) {
    final tabNavigatorState = of(context);
    if (setToCurrent &&
        tabIndex != tabNavigatorState.tabIndex &&
        tabNavigatorState.mounted) {
      // ignore: invalid_use_of_protected_member
      tabNavigatorState.setState(() {
        tabNavigatorState.tabIndex = tabIndex;
      });
    }
    return tabNavigatorState.navStates[tabIndex].currentState;
  }

  static void switchTabTo(BuildContext context, {@required int tabIndex}) {
    tabNavigatorOf(context, tabIndex: tabIndex, setToCurrent: true);
  }

  /// Pushes the [route] to the current or [tabIndex] tab
  static void navigateTo(
    BuildContext context, {
    int tabIndex,
    @required Route route,
  }) {
    final tabNavigatorState = of(context);

    tabNavigatorOf(
      context,
      tabIndex: tabIndex ?? tabNavigatorState.tabIndex,
      setToCurrent: true,
    ).push(
      route,
    );
  }
}

class _NestedNavigatorTabsState extends State<NestedNavigatorTabs> {
  int tabIndex = 0;

  List<GlobalKey<NavigatorState>> navStates;

  @override
  void initState() {
    tabIndex = widget.initialTab;
    navStates = widget._defaultRouteNames
        .map((p) => GlobalKey<NavigatorState>())
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bottomBar = widget.bottomBarBuilder
            ?.call(context, widget._navItems, tabIndex, onTapNav) ??
        BottomNavigationBar(
          items: widget._navItems,
          currentIndex: tabIndex,
          onTap: onTapNav,
        );

    return WillPopScope(
      onWillPop: () async {
        if (navStates[tabIndex].currentState.canPop() &&
            widget.popNestedRouteOnBack) {
          navStates[tabIndex].currentState.pop();
          return false;
        }
        return true;
      },
      child: widget.layoutBuilder
              ?.call(context, _buildContainer(), bottomBar, tabIndex) ??
          Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: _buildContainer(),
            bottomNavigationBar: bottomBar,
          ),
    );
  }

  IndexedStack _buildContainer() {
    return IndexedStack(
      index: tabIndex,
      children: widget._defaultRouteNames.map(
        withIndex(
          (initialPage, index) {
            return Navigator(
              key: navStates[index],
              initialRoute: initialPage,
              onGenerateRoute: widget.generator,
            );
          },
        ),
      ).toList(),
    );
  }

  void onTapNav(int index) {
    // double tap
    if (index == tabIndex) {
      if (widget.clearStackOnDoubleTap) {
        navStates[index].currentState.popUntil((route) => route.isFirst);
      }
    } else if (mounted) {
      setState(() {
        tabIndex = index;
      });
    }
  }
}

class NavigatorTab {
  final String defaultRouteName;
  final BottomNavigationBarItem navItem;

  NavigatorTab({@required this.defaultRouteName, @required this.navItem});
}

typedef MapFn<A, B> = B Function(A a);

typedef IndexedMapFn<A, B> = B Function(A a, int index);

/// helper for mapping with an index
MapFn<A, B> withIndex<A, B>(IndexedMapFn<A, B> mapFn) {
  int index = -1;
  return (A a) => mapFn(a, ++index);
}
