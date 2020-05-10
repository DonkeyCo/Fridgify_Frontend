
import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/item.dart';
import 'package:logger/logger.dart';

class AddItemController {
  StoreRepository _storeRepository = StoreRepository();
  ItemRepository _itemRepository = ItemRepository();
  ContentRepository contentRepository;
  Logger _logger = Logger();

  TextEditingController itemNameController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController itemAmountController = TextEditingController();
  TextEditingController itemUnitController = TextEditingController();
  TextEditingController itemStoreController = TextEditingController();
  String barcode = "";

  AddItemController({this.contentRepository});


  Future<Content> addContent() async {
    _logger.i("AddItemController => ADDING ITEM ${itemNameController.text} ${expirationDateController.text} ${itemCountController.text}"
        "${itemAmountController.text} ${itemUnitController.text} ${itemStoreController.text}");


    Content c = Content.create(
        amount: int.parse(itemAmountController.text),
        expirationDate: "${expirationDateController.text}",
        unit: itemUnitController.text,
        count: int.parse(itemCountController.text),
        item: Item.create(name: itemNameController.text,
            store: await _storeRepository.getByName(itemStoreController.text))
    );

    try {
      _logger.i("AddItemController => ADDING CONTENT $c");
      await this.contentRepository.add(c);
      await this._itemRepository.fetchAll();
      return c;
    }
    catch(exception) {
      _logger.e("AddItemController => FAILED TO ADD ITEM $exception");
      throw FailedToAddContentException;
    }
  }

}