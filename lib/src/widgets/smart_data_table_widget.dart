import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_common_shared/smart_common_shared.dart';
import 'package:smart_table/src/common/data_grid_source.dart';
import 'package:smart_table/src/common/paginated_data_table.dart';
import 'package:smart_table/src/models/action_button_model.dart';
import 'package:smart_table/src/models/data_table_field_model.dart';
import 'package:smart_tags/smart_tags.dart';
import 'dart:developer' as dev;

import 'package:smart_translation/smart_translation.dart';

String devName = '[Package]-smart_table';

class SmartDataTable extends StatefulWidget {
  final dynamic model;
  final List<dynamic> data;
  final List<ActionButton>? rowActionButtons;
  final List<ActionButton>? headerActionButtons;
  final bool? showSearch;
  final List<int>? hiddenColumns;
  final Function? onTapOrClick;
  final bool? sort;
  final int? selectedSort;
  final String? clearAllResourceTranslation;
  final bool? showFirstLastButtons;
  final BuildContext appContext;
  final Function(bool value) onShowDeleteItemsChange;
  final bool showDeleted;
  final Function(dynamic data)? onDownloadReport;

  const SmartDataTable({
    Key? key,
    required this.model,
    required this.data,
    this.rowActionButtons,
    this.headerActionButtons,
    this.showSearch,
    this.hiddenColumns,
    this.onTapOrClick,
    this.sort,
    this.selectedSort,
    this.clearAllResourceTranslation,
    this.showFirstLastButtons,
    required this.appContext,
    required this.onShowDeleteItemsChange,
    required this.showDeleted,
    this.onDownloadReport
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SmartDataTableState();
  }
}

class _SmartDataTableState extends State<SmartDataTable> {

  late int _defaultRowsPerPage;
  late bool _showSearch;
  late bool _sort;
  late int _selectedSort;
  late String _clearAllResourceTranslation;
  late List<DataColumn> _columns;
  late bool _showFirstLastButtons;
  final List<Widget> _headerActions = <Widget>[];
  late ScrollController _scrollController;
  late int _originalRowsPerPage;
  List<dynamic> _searchList = <dynamic>[];

  @override
  void initState() {
    super.initState();
    dev.log('initState', name: devName);
    _scrollController = ScrollController();
    _columns =
        getColumns(widget.appContext, widget.model, widget.rowActionButtons);
    _defaultRowsPerPage = 5;
    _originalRowsPerPage = _defaultRowsPerPage;
    if (widget.showSearch == null) {
      _showSearch = false;
    } else {
      _showSearch = widget.showSearch!;
    }
    if (widget.sort == null) {
      _sort = false;
    } else {
      _sort = widget.sort!;
    }
    if (widget.selectedSort == null) {
      _selectedSort = 0;
    } else {
      if (widget.selectedSort! > _columns.length) {
        if (widget.rowActionButtons != null) {
          int qty = widget.rowActionButtons!.length + 1;
          _selectedSort = _columns.length - qty;
        } else {
          _selectedSort = _columns.length - 1;
        }
      } else {
        _selectedSort = widget.selectedSort!;
      }
    }
    if (widget.showFirstLastButtons == null) {
      _showFirstLastButtons = true;
    } else {
      _showFirstLastButtons = widget.showFirstLastButtons!;
    }

    if (widget.clearAllResourceTranslation == null) {
      _clearAllResourceTranslation = 'Clear all';
    } else {
      _clearAllResourceTranslation = widget.clearAllResourceTranslation!;
    }
    _searchList = widget.data;
    if (widget.headerActionButtons != null) {
      for (ActionButton element in widget.headerActionButtons!) {
        _headerActions.add(IconButton(
          icon: element.icon,
          onPressed: element.action,
          iconSize: 35,
          alignment: Alignment.center,
        ));
      }
    }
  }

  _searchData(List<String> tags) {
    dev.log('searchData', name: devName);
    if (tags.isEmpty) {
      setState(() {
        _searchList = widget.data;
      });
    } else {
      List<dynamic> newSearchList = widget.data;
      List<dynamic> tempSearchList = <dynamic>[];
      for (String tag in tags) {
        for (dynamic row in newSearchList) {
          bool found = false;
          widget.model.getFields(widget.appContext).forEach((dynamic field) {
            if (row
                .getProp(field.systemName)
                .toString()
                .toLowerCase()
                .contains((tag.toLowerCase()))) {
              found = true;
            }
          });
          if (found) {
            tempSearchList.add(row);
          }
        }
        newSearchList = tempSearchList;
        tempSearchList = <dynamic>[];
      }
      setState(() {
        _searchList = newSearchList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dev.log('build', name: devName);
    List<int> _rowsPerPage = <int>[5, 10, 20, 30, 50];
    Widget search = const Text('');
    if (_showSearch) {
      search = TextFieldTags(
        tagsStyler: TagsStyler(
          tagTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
          tagDecoration: BoxDecoration(
            color: Theme.of(widget.appContext).colorScheme.primary,
            borderRadius: BorderRadius.circular(2.0),
          ),
          tagCancelIcon:
              const Icon(Icons.cancel, size: 16.0, color: Colors.white),
          tagPadding: const EdgeInsets.all(8.0),
        ),
        textFieldStyler: TextFieldStyler(
          textFieldBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(widget.appContext).colorScheme.secondary),
          ),
          hintText: AppLocalizations.of(context)!
              .translate(SmartApplications.package_smart_table, 'search'),
        ),
        onDelete: (String delete) {
          //print('onDelete: $delete');
        },
        onTag: (String tag) {
          //print('onTag: $tag');
        },
        onList: (List<String> listTag) {
          _searchData(listTag);
          if (listTag.length > 1) {
            String filter = listTag.firstWhere(
                (String element) =>
                    element.startsWith('|---') && element.endsWith('---|'),
                orElse: () => '');
            if (filter == '') {
              listTag.insert(0, '|---$_clearAllResourceTranslation---|');
            }
          }
        },
      );
    }

    return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomPaginatedDataTable(
                  showDeleted: widget.showDeleted,
                  onShowDeletedChanged: (bool value)
                  {
                    widget.onShowDeleteItemsChange(value);
                  },
                  actions: _headerActions,
                  header: search,
                  showFirstLastButtons: _showFirstLastButtons,
                  sortAscending: _sort,
                  sortColumnIndex: _selectedSort,
                  rowsPerPage: _defaultRowsPerPage,
                  availableRowsPerPage: _rowsPerPage,
                  showCheckboxColumn: false,
                  onRowsPerPageChanged: (int? value) {
                    setState(() {
                      _defaultRowsPerPage = value!;
                    });
                  },
                  columns: _columns,
                  source: SmartDataTableSource(
                      context: widget.appContext,
                      listData: _searchList,
                      model: widget.model,
                      actionButtons: widget.rowActionButtons,
                      hiddenColumns: widget.hiddenColumns,
                      onTapOrClick: widget.onTapOrClick))
            ],
          ),
    );
  }

  List<DataColumn> getColumns(
      BuildContext context, dynamic model, List<ActionButton>? actionButtons) {
    List<DataColumn> columns = <DataColumn>[];
    List<DataTableField> fields = model.getFields(context);
    int columnCounter = 0;
    for (DataTableField e in fields) {
      bool hideColumn = false;
      if (widget.hiddenColumns != null && widget.hiddenColumns!.isNotEmpty) {
        for (int element in widget.hiddenColumns!) {
          if (element == columnCounter) {
            hideColumn = true;
          }
        }
      }
      if (!hideColumn) {
        columns.add(DataColumn(
            onSort: (int columnIndex, bool ascending) {
              setState(() {
                _sort = !_sort;
                _selectedSort = columnIndex;
              });
              _onSortColumn(ascending, e.systemName);
            },
            label: Text(e.readableName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
      columnCounter++;
    }
    if (widget.rowActionButtons != null) {
      if (widget.rowActionButtons!.length > 1) {
        columns.add(DataColumn(
            label: Text(
                AppLocalizations.of(context)!
                    .translate(SmartApplications.package_smart_table, 'actions'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      } else {
        for (ActionButton element in widget.rowActionButtons!) {
          columns.add(DataColumn(
              label: Text(element.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold))));
        }
      }
    }
    return columns;
  }

  _onSortColumn(bool ascending, String field) {
    _searchList.customSort(ascending, field);
  }
}

extension MultiSort on List<dynamic> {
  customSort(bool asc, String field) {
    if (asc) {
      sort((dynamic a, dynamic b) =>
          a.getProp(field).compareTo(b.getProp(field)));
    } else {
      sort((dynamic a, dynamic b) =>
          b.getProp(field).compareTo(a.getProp(field)));
    }
  }
}
