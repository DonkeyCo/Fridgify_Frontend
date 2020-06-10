import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreRepository implements Repository<Store, int> {
  Logger _logger = Logger('StoreRepository');
  SharedPreferences sharedPreferences = Repository.sharedPreferences;
  Dio dio;

  static final storeApi = "${Repository.baseURL}stores/";

  Map<int, Store> stores = Map();
  Map<Store, String> storeWithNames = Map();

  static final StoreRepository _storeRepository = StoreRepository._internal();

  factory StoreRepository([Dio dio]) {
    _storeRepository.dio = Repository.getDio(dio);

    return _storeRepository;
  }

  StoreRepository._internal();

  Future<Store> getByName(String name) async {
    if(this.getAllWithName().values.contains(name)) {
      print("Found");
      return this.getAllWithName().keys.firstWhere((element) => element.name == name);
    }
    print("Not Found");
    Store s = Store.create(name: name);
    stores[await add(s)] = s;
    return s;
  }

  @override
  Future<int> add(Store store) async {
    var response = await dio.post(storeApi,
        data: jsonEncode({
          "name": store.name,
        }),
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('ADDING STORE: ${response.data}');

    if (response.statusCode == 201) {
      var s = response.data;
      var store = Store(storeId: s['store_id'], name: s['name']);
      _logger.i("CREATED SUCCESSFUL $store");

      this.stores[store.storeId] = store;

      return store.storeId;
    }

    throw FailedToAddContentException();
  }

  @override
  Future<bool> delete(int id) {
    // TODO: implement delete
    return null;
  }

  @override
  Future<Map<int, Store>> fetchAll() async {
    _logger.i('FETCHING FROM URL: $storeApi');

    var response = await dio.get(storeApi,
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('FETCHING STORES: ${response.data}');

    if (response.statusCode == 200) {
      var stores = response.data;

      _logger.i('$stores');


      for (var store in stores) {
        _logger.i("FETCHED STORES: $store");
        Store s = Store.fromJson(store);
        this.storeWithNames[s] = s.name;
        this.stores[s.storeId] = s;


      }

      _logger.i("FETCHED ${this.stores.length} ITEMS");
      return this.stores;
    }
    throw new FailedToFetchContentException();
  }


  @override
  get(int id) {
    return this.stores[id];
  }

  Map<Store, String> getAllWithName() {
    return storeWithNames;
  }

  @override
  Map<int, Store> getAll() {
    return this.stores;
  }
}
