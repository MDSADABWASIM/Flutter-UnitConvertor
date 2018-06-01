import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:udacity_project/Unit.dart';
import 'package:udacity_project/category.dart';
import 'api.dart';

class ConvertorScreen extends StatefulWidget {
  final Category category;

  const ConvertorScreen({@required this.category}) : assert(category != null);

  @override
  _ConvertorScreenState createState() => new _ConvertorScreenState();
}

class _ConvertorScreenState extends State<ConvertorScreen> {
  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  String _convertedValue = '';
  List<DropdownMenuItem> _unitMenuItems;
  bool _showValidationError = false;
  var _padding = EdgeInsets.all(16.0);
  //pass this key to the input Text field so the input value persist.
  final _inputKey = GlobalKey(debugLabel: 'inputText');
  bool _showErrorUI = false;

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  @override
  void didUpdateWidget(ConvertorScreen old) {
    super.didUpdateWidget(old);
    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropdownMenuItems();
      _setDefaults();
    }
  }

  /// Creates fresh list of [DropdownMenuItem] widgets, given a list of [Unit]s.
  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  /// Sets the default values for the 'from' and 'to' [Dropdown]s.
  void _setDefaults() {
    setState(() {
      _fromValue = widget.category.units[0];
      _toValue = widget.category.units[1];
    });
  }

  void _updateConversion() async{
    if (widget.category.name == apiCategory['name']) {
      final Api = api();
      final conversion = await Api.convert(apiCategory['route'],
          _inputValue.toString(), _fromValue.name, _toValue.name);
      // TODO: Check whether to show an error UI
      // API error or not connected to the internet
      if (conversion == null) {
        setState(() {
          _showErrorUI = true;
        });
      } else {
        setState(() {
          _convertedValue = _format(conversion);
        });
      }
   
    } else {
      // For the static units, we do the conversion ourselves
      setState(() {
        _convertedValue = _format(
            _inputValue * (_toValue.conversion / _fromValue.conversion));
      });
    }
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3'
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print('Error: $e');
          _showValidationError = true;
        }
      }
    });
  }

  Unit _getUnit(String unitName) {
    return widget.category.units.firstWhere(
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        // This sets the color of the [DropdownButton] itself
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        // This sets the color of the [DropdownMenuItem]
        data: Theme.of(context).copyWith(
              canvasColor: Colors.grey[50],
            ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                value: currentValue,
                items: _unitMenuItems,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  @override
  Widget build(BuildContext context) {

    //if theres an api error.
  if (widget.category.units == null ||
        (widget.category.name == apiCategory['name'] && _showErrorUI)) {
      return SingleChildScrollView(
        child: Container(
          margin: _padding,
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: widget.category.color['error'],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 180.0,
                color: Colors.white,
              ),
              Text(
                "Oh no! We can't connect right now!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      );
    }


    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: _inputKey,
            style: Theme.of(context).textTheme.display1,
            decoration: InputDecoration(
              labelStyle: Theme.of(context).textTheme.display1,
              errorText: _showValidationError ? 'Invalid number entered' : null,
              labelText: 'Input',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          _createDropdown(_fromValue.name, _updateFromConversion),
        ],
      ),
    );

    final arrow = RotatedBox(
      quarterTurns: 1,
      child: new Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );
    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              labelText: 'Output',
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdown(_toValue.name, _updateToConversion),
        ],
      ),
    );

    final convertor = ListView(
      children: <Widget>[
        new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            input,
            arrow,
            output,
          ],
        ),
      ],
    );

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (orientation == Orientation.landscape) {
          return new Container(
            child: convertor,
          );
        } else {
          return new Center(
            child: new Container(
              width: 450.0,
              child: convertor,
            ),
          );
        }
      },
    );
  }
}
