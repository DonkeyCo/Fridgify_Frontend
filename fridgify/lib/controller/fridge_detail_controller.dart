
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/view/popups/add_item_popup.dart';
import 'package:fridgify/view/popups/edit_value_popup.dart';
import 'package:fridgify/view/popups/no_item_found_popup.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:logger/logger.dart';

class FridgeDetailController {
  Function setState;
  Fridge fridge;
  Logger _logger = Logger();

  bool isEditMode = false;
  List<Content> contents;

  BuildContext context;

  List<Content> _selected = List();

  ItemRepository _itemRepository = ItemRepository();

  FridgeDetailController(this.setState, this.fridge);

  Future<void> handleOptions(String string, BuildContext context) async {
    if(string == Constants.addItem) {
      _logger.i("DetailController => ADDING ITEM");

      Item item;

      var result = await BarcodeScanner.scan();

      print(result.type); // The result type (barcode, cancelled, failed)
      print(result.rawContent); // The barcode content
      print(result.format); // The barcode format (as enum)
      print(result.formatNote); // If a unknown format was scanned this field contains a note

      _logger.i("DetailController => SCANNED BARCODE ${result.type}");

      if(result.type == ResultType.Barcode || !(result.type == ResultType.Cancelled)) {
        item = await findItem(result);
        _logger.i("DetailController => FOUND ITEM ${item}");

        if(item == null) {
          _logger.i("DetailController => NO ITEM FOUND");
          await showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return NoItemFoundPopUp();
              }
          );
        }
      }

      showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AddItemPopUp(this.fridge.contentRepository, item, context, setState);
          });
    }
    setState(() {});
  }

  Future<Item> findItem(ScanResult result) async {
    _logger.i("DetailController => LOCATING ITEM ${result.rawContent}");
    if(isValidBarcode(result.format)) {
      _logger.i("DetailController => FORMAT ${result.format}");
      return await _itemRepository.barcode(result.rawContent);
    }
    return null;
  }

  bool isValidBarcode(BarcodeFormat format) {
    return !(format == BarcodeFormat.qr || format == BarcodeFormat.aztec ||
        format == BarcodeFormat.dataMatrix || format == BarcodeFormat.unknown ||
        format == BarcodeFormat.interleaved2of5 || format == BarcodeFormat.pdf417
    );
  }

  showEditDialog(ContentRepository repository, content,
      BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return EditValuePopUp(repository, content, context, setState);
        });
  }

  cancelSelection() {
    setState(() {
      _selected = List();
      isEditMode = false;
    });
  }

  selectGroup(List<Content> group) {
    isEditMode = true;
    _selected.addAll(group);
    setState(() {});
    print("Long");
  }

  groupTap(group, ExpandableController expandableController) {
    if(isEditMode) {
      print("Edit mode");
      _selected.addAll(group);
    }
    else {
      print("Edit mode1");
      expandableController.toggle();
    }

    setState(() {});
  }

  tileTapped(ContentRepository repo, Content content, BuildContext context) {
    isEditMode ?
    toggleSelection(content) :
    showEditDialog(repo, content, context);
  }

  deleteSelection(BuildContext context) {
    this.context = context;
    setState(() {
      Popups.confirmationPopup(
          context,
          "Delete ${_selected.length} items?", "Are you sure you would like to delete ${_selected.length} items from ${this.fridge.name}? It can't be undone.",
          _deleteItems
      );
    });
  }

  void toggleSelection(Content content) {
    this.isEditMode = true;
    setState(() {
      if (this._selected.contains(content)) {
        this._selected.remove(content);
      } else {
        this._selected.add(content);
      }
    });
  }

  Future<bool> _deleteItems() async {
    Loader.showSimpleLoadingDialog(this.context);
    try {
      await Future.wait(
        this._selected.map((e) => fridge.contentRepository.delete(e.contentId))
      );
      fridge.contentRepository.group(fridge.contentRepository.getAll());
      setState(() {});
      cancelSelection();
      Navigator.of(this.context).pop();
      return true;
    }
    catch (exception) {
      _logger.e("FridgeDetailController => FAILED TO DELETE ITEMS $exception");
      cancelSelection();
      Navigator.of(this.context).pop();
      return false;
    }
  }

  bool isSelected(Content content) {
    return _selected.contains(content);
  }

}