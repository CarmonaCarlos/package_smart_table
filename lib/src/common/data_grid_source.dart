import 'package:flutter/material.dart';
import 'package:smart_common_shared/smart_common_shared.dart';
import 'package:smart_common_shared/ui/widgets/dialogs_widget.dart';
import 'package:smart_table/smart_table.dart';
import 'package:smart_table/src/common/map/icon_button_state_map.dart';
import 'package:smart_table/src/models/action_button_model.dart';
import 'package:smart_table/src/models/data_table_field_model.dart';
import 'package:smart_translation/smart_translation.dart';

class SmartDataTableSource extends DataTableSource {
  List<dynamic> listData;
  dynamic model;
  BuildContext context;
  List<ActionButton>? actionButtons;
  bool? showCounter;
  List<int>? hiddenColumns;
  Function? onTapOrClick;

  late List<DataTableField> _fields;
  late int _counter;
  late int _selectedRowCount;

  SmartDataTableSource(
      {required this.listData,
      required this.model,
      required this.context,
      this.actionButtons,
      this.showCounter,
      this.hiddenColumns,
      this.onTapOrClick}) {
    showCounter ??= false;
    hiddenColumns ??= <int>[];
    _fields = model.getFields(context);
    _counter = listData.length;
    _selectedRowCount = 0;
  }

  @override
  DataRow? getRow(int index) {
    if (index >= 0) {
      if (index >= listData.length) return null;
      final dynamic rowData = listData[index];
      return DataRow.byIndex(
          cells: getCells(rowData),
          index: index,
          selected: rowData.selected,
          onSelectChanged: (bool? isSelected) {
            rowData.selected = isSelected;
            notifyListeners();
          });
    }
  }

  List<DataCell> getCells(dynamic data) {
    List<DataCell> cells = <DataCell>[];
    //Be careful and remember to initialize showCounter class property, otherwise you will get an exception, thanks null safety!
    if (showCounter!) cells.add(DataCell(SelectableText(_counter.toString())));
    _counter--;
    int columnCounter = 0;
    for (DataTableField element in _fields) {
      bool hideColumn = false;
      //Be careful and remember to initialize hiddenColumns, otherwise you will get a beautiful exception
      if (hiddenColumns!.isNotEmpty) {
        for (int column in hiddenColumns!) {
          if (column == columnCounter) {
            hideColumn = true;
          }
        }
      }
      if (!hideColumn) {
        String value = '';
        value = data.getProp(element.systemName).toString();
        if (element.isWidget!) {
          switch (element.widgetType) {
            case DataTableWidgetType.iconButtonState:
              cells.add(DataCell(Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  iconState[value]!,
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate(
                        SmartApplications.package_smart_table,
                        value.toLowerCase()),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              )));
              break;
            case DataTableWidgetType.image:
              //TODO: handle this case
              break;
            default:
              //TODO: handle this case
              break;
          }
        } else {
          cells.add(DataCell(SelectableText(value), onTap: () {
            if (onTapOrClick != null) {
              onTapOrClick!(data);
            }
          }));
        }
      }
      columnCounter++;
    }

    if (actionButtons != null) {
      bool isDeleted = false;
      try{
        if(data.active == 2){
          isDeleted = true;
        }else{
          isDeleted = false;
        }
      }catch(e){
        //TODO log error
        isDeleted = false;
      }
      if(!isDeleted){
        if (actionButtons!.length > 1) {
          List<ListTile> menuItems = <ListTile>[];
          for (ActionButton actionButton in actionButtons!) {
            menuItems.add(ListTile(
                title: Text(
                  actionButton.title,
                ),
                onTap: () {
                  Navigator.pop(context);
                  actionButton.action!(data);
                },
                trailing: actionButton.icon));
          }
          cells.add(DataCell(IconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: AppLocalizations.of(context)!
                .translate(SmartApplications.package_smart_table, 'actions'),
            onPressed: () {
              Dialogs.showActionButtonsDialog(
                  context: context, actionButtonsListTile: menuItems);
            },
          )));
        } else {
          for (ActionButton actionButton in actionButtons!) {
            cells.add(DataCell(IconButton(
              onPressed: () {
                actionButton.action!(data);
              },
              icon: actionButton.icon,
              color: Theme.of(context).colorScheme.secondary,
            )));
          }
        }
      }else{
        cells.add(DataCell(Container()));
      }

    }
    return cells;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => listData.length;

  @override
  int get selectedRowCount => _selectedRowCount;
}
