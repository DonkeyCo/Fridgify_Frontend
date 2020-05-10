import 'dart:convert';
import 'dart:math';

import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:http/http.dart';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemRepository implements Repository<Item, int> {
  Fridge fridge;
  Logger logger = Repository.logger;
  SharedPreferences sharedPreferences = Repository.sharedPreferences;
  StoreRepository storeRepository = StoreRepository();
  Client client;

  static const itemApi = "${Repository.baseURL}items/";

  Map<int, Item> items = Map();

  static final ItemRepository _itemRepository = ItemRepository._internal();

  factory ItemRepository([Client client]) {
    if (client != null) {
      _itemRepository.client = client;
    } else {
      _itemRepository.client = Client();
    }

    return _itemRepository;
  }

  ItemRepository._internal();

  @override
  Future<int> add(item) async {
    if(items.containsValue(item)) {
      return this.items.values.firstWhere((element) => element == item).itemId;
    }
    int id = 100000 + Random().nextInt(1000);
    items[id] = item;
    return id;
  }

  Future<Item> barcode(String barcode) {
    return null;
  }

  @override
  Future<bool> delete(int id) async {
    // TODO: implement delete
    return null;
  }

  @override
  Future<Map<int, Item>> fetchAll() async {
    logger.i('ItemRepository => FETCHIN FROM URL: $itemApi');

    var response = await client.get(itemApi, headers: Repository.getHeaders());

    logger.i('ItemRepository => FETCHING ITEMS: ${response.body}');

    if (response.statusCode == 200) {
      var items = jsonDecode(response.body);

      logger.i('ItemRepository => $items');

      for (var item in items) {
        logger.i("ItemRepository => FETCHED ITEMS: ${item.toString()}");
        Item i = Item(
            itemId: item['item_id'],
            barcode: item['barcode'],
            name: item['name'],
            store: storeRepository.get(item['store']));
        this.items[i.itemId] = i;
      }

      logger.i("ItemRepository => FETCHED ${this.items.length} ITEMS");
      return this.items;
    }
    throw new FailedToFetchContentException();
  }

  @override
  Item get(int id) {
    return this.items[id];
  }

  @override
  Map<int, Item> getAll() {
    return this.items;
  }
}
