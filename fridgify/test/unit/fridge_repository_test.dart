import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  FridgeRepository fridgeRepository;
  FridgeRepositoryTestUtil testUtil;
  Dio mockDio;
  Fridge fridge;
  Repository.isTest = true;


  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('apiToken', 'Test token');

    mockDio = new Dio();
    testUtil = FridgeRepositoryTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case "Add":
          return testUtil.handleAddRequest(request);
        case "Delete":
          return testUtil.handleDeleteRequest(request);
        case 'Fetch all':
          return testUtil.handleFetchAllRequest(request);
        case 'Get fridge member':
          return testUtil.handleGetFridgeMemberRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    fridgeRepository = FridgeRepository(mockDio);

    fridge = Fridge.create(
        fridgeId: 69, name: 'Test fridge');
  });

  group('add', () {
    setUp(() {
      testUtil.setTestCase('Add');
    });

    test('throws an error', () async {
      testUtil.setId('Error case add fridge');

      expect(
          () async => completion(await fridgeRepository.add(fridge)),
          throwsA(
              predicate((error) => error is FailedToCreateNewFridgeException)));
    });

    test('creates successfully', () async {
      testUtil.setId('Create fridge');

      expect(Future.value(69), completion(await fridgeRepository.add(fridge)));
      expect(fridge.name, fridgeRepository.fridges[69].name);
    });
  });

  group('delete', () {
    setUp(() {
      testUtil.setTestCase('Delete');
    });

    test('doesnt delete', () async {
      testUtil.setId('Doesnt delete');

      expect(
          Future.value(false), completion(await fridgeRepository.delete(13)));
    });

    test('deletes successfully', () async {
      testUtil.setId('Delete');

      fridgeRepository.fridges[123] = Fridge.create(
          fridgeId: 123,
          name: 'Fridge to delete',
      );

      expect(
          Future.value(true), completion(await fridgeRepository.delete(123)));
      expect(false, fridgeRepository.fridges.containsKey(66));
    });
  });

  group('fetchAll', () {
    setUp(() {
      testUtil.setTestCase('Fetch all');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch all');

      expect(
          () async => completion(await fridgeRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchFridgesException)));
    });

    test('adds all of the returned fridges', () async {
      testUtil.setId('Add fridges');

      var content = await fridgeRepository.fetchAll();

      // Should have 13 entries
      for (int i = 0; i < 13; i++) {
        expect(true, fridgeRepository.fridges.containsKey(i));
      }
    });
  });

  group('getFridgeMembers', () {
    setUp(() {
      testUtil.setTestCase('Get fridge member');
    });

    test('throws an error', () async {
      testUtil.setId('Error case get fridge members');

      expect(
          () async =>
              completion(await fridgeRepository.getFridgeMembers(fridge)),
          throwsA(
              predicate((error) => error is FailedToFetchFridgesException)));
    });

    test('returns all members', () async {
      testUtil.setId('Return member');

      var members = await fridgeRepository.getFridgeMembers(fridge);

      for (int i = 0; i < members.length; i++) {
        expect(
            'username: Mr. Mock No.$i, password: , name: Dieter No.$i, surname: Mock No.$i, email: dieter.mockNo.$i@gmail.de, birthDate: 01.01.1969',
            members[i].toString());
      }
    });
  });
}

class FridgeRepositoryTestUtil extends TestUtil {
  FridgeRepositoryTestUtil(Dio dio) : super(dio);

  Map body;

  Response handleAddRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case add content':
        return Response(data: 'Error case add fridge', statusCode: 404);
      case 'Create fridge':
        return Response(data: {
          'fridge_id': 69,
          'name': 'Test fridge'
        }, statusCode: 201);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleDeleteRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Doesnt delete':
        return Response(data: 'Doesnt delete', statusCode: 404);
      case 'Delete':
        return Response(data: '', statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleFetchAllRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch all':
        return Response(data: 'Error case fetch all', statusCode: 404);
      case 'Add fridges':
        Response response = Response(data: createFridgeObjects(13), statusCode: 200);
        setId('Return member in fetch all');
        return response;
      case 'Return member in fetch all':
        Response response = Response(data: createMemberObjects(13), statusCode: 200);
        setId('Add content in fetch all');
        return response;
      case 'Add content in fetch all':
        return Response(data: [], statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleGetFridgeMemberRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case get fridge members':
        return Response(data: 'Error case get fridge members', statusCode: 404);
      case 'Return member':
        return Response(data: createMemberObjects(13), statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }


  List<Object> createMemberObjects(int amount) {
    List<Object> member = List();

    for (int i = 0; i < amount; i++) {
      member.add({
        'username': 'Mr. Mock No.$i',
        'name': 'Dieter No.$i',
        'surname': 'Mock No.$i',
        'email': 'dieter.mockNo.$i@gmail.de',
        'birth_date': '01.01.1969'
      });
    }
    return member;
  }

  List<Object> createFridgeObjects(int amount) {
    List<Object> fridges = List();

    for (int i = 0; i < amount; i++) {
      fridges.add({
        'id': i,
        'name': 'Fridge No. $i',
        'content': {
          'total': i + 120,
          'fresh': i + 52,
          'dueSoon': i + 51,
          'overDue': i,
        }
      });
    }

    return fridges;
  }
}
