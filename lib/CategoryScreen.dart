import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:udacity_project/Unit.dart';
import 'package:udacity_project/category.dart';
import 'package:udacity_project/category_tile.dart';
import 'package:udacity_project/ConvertorScreen.dart';
import 'package:udacity_project/Backdrop.dart';
import 'api.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => new _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
 
  Category _defaultCategory;
  Category _currentCategory;
  var categories = <Category>[];

  // wait for our JSON asset to be loaded in (async).
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // We have static unit conversions located in our
    // lib/assets/data/regular_units.json
    if (categories.isEmpty) {
      await _retrieveLocalCategories();
      await _retrieveApiCategories();
    }
  }

  /// Retrieves a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    final json = DefaultAssetBundle
        .of(context)
        .loadString('lib/assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);

   var categoryIndex = 0;
    data.keys.forEach((key) {
      final List<Unit> units =
          data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();

      var category = Category(
        name: key,
        units: units,
        color: _baseColors[categoryIndex],
        icon: _IconsList[categoryIndex],
      );
      setState(() {
        if (categoryIndex == 0) {
          _defaultCategory = category;
        }
        categories.add(category);
      });
      categoryIndex += 1;
    });
  }

  /// Retrieves a [Category] and its [Unit]s from an API on the web
  Future<void> _retrieveApiCategories() async {
    // Add a placeholder while we fetch the Currency category using the API
    setState(() {
      categories.add(Category(
        name: apiCategory['name'],
        units:<Unit>[],
        color: _baseColors.last,
        icon: _IconsList.last,
      ));
    });
    final Api = api();
    final jsonUnits = await Api.getUnit(apiCategory['route']);
    // If the API errors out or we have no internet connection, this category
    // remains in placeholder mode (disabled)
    if (jsonUnits != null) {
      final units = <Unit>[];
      for (var unit in jsonUnits) {
        units.add(Unit.fromJson(unit));
      }
      setState(() {
        categories.removeLast();
        categories.add(Category(
          name: apiCategory['name'],
          units: units,
          color: _baseColors.last,
          icon: _IconsList.last,
        ));
      });
    }
  }


  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];

  static const _IconsList = <String>[
   
      'lib/assets/icons/area.png',
      'lib/assets/icons/currency.png',
      'lib/assets/icons/digital_storage.png',
      'lib/assets/icons/length.png',
      'lib/assets/icons/mass.png',
      'lib/assets/icons/power.png',
      'lib/assets/icons/time.png',
      'lib/assets/icons/volume.png',
  ];

  Widget _buildCategoryWidgets(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
           var _category= categories[index];
          return CategoryTile(
          
            category: _category,
             onTap: _category.name == apiCategory['name'] && _category.units.isEmpty
                    ? null
                    : _onCategoryTap,
          );
        },
        itemCount: categories.length,
      );
    } else {
      return new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: categories.map((Category c) {
          return CategoryTile(
            category: c,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ///to show the list of categories.
    assert(debugCheckHasMediaQuery(context));
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );

    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? ConvertorScreen(category: _defaultCategory)
          : ConvertorScreen(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }
}
