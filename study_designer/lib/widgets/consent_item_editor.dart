import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/consent/consent_item.dart';

class ConsentItemEditor extends StatefulWidget {
  final ConsentItem consentItem;
  final void Function() remove;

  const ConsentItemEditor({@required this.consentItem, @required this.remove, Key key}) : super(key: key);

  @override
  _ConsentItemEditorState createState() => _ConsentItemEditorState();
}

class _ConsentItemEditorState extends State<ConsentItemEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  Future<void> _pickIcon() async {
    final icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.custom,
        customIconPack: {for (var key in MdiIcons.getIconsName()) key: MdiIcons.fromString(key)});

    final iconName = iconMap.keys.firstWhere((k) => iconMap[k] == icon.codePoint, orElse: () => null);
    setState(() {
      widget.consentItem.iconName = iconName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            ListTile(
                title: Text('Consent Item'),
                trailing: FlatButton(onPressed: widget.remove, child: const Text('Delete'))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                FormBuilder(
                    key: _editFormKey,
                    autovalidate: true,
                    // readonly: true,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'title',
                            maxLength: 40,
                            decoration: InputDecoration(labelText: 'Title'),
                            initialValue: widget.consentItem.title),
                        Row(children: [
                          Expanded(
                            child: FlatButton(
                              onPressed: _pickIcon,
                              child: Text('Choose Icon'),
                            ),
                          ),
                          if (MdiIcons.fromString(widget.consentItem.iconName) != null)
                            Expanded(child: Icon(MdiIcons.fromString(widget.consentItem.iconName)))
                        ]),
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: 'Description'),
                            initialValue: widget.consentItem.description),
                      ],
                    )),
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.consentItem.title = _editFormKey.currentState.value['title'];
        widget.consentItem.description = _editFormKey.currentState.value['description'];
      });
    }
  }
}