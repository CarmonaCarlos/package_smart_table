import 'package:smart_table/src/common/enum/widget_type.dart';

class DataTableField {
  String systemName;
  String readableName;
  String? fieldType;
  dynamic dataSource;
  bool? isWidget;
  DataTableWidgetType? widgetType;
  dynamic value;
  DataTableField({required this.systemName, required this.readableName, this.fieldType, this.dataSource, this.isWidget, this.widgetType, this.value }) {
    fieldType ??= '';
    dataSource ??= '';
    isWidget ??= false;
    widgetType ??= DataTableWidgetType.iconButtonState;
    value ??= '';
  }
}
