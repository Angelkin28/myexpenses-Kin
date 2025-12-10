import 'package:dio/dio.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/errors/failures.dart';
import '../models/expense_model.dart';

class ExpensesRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _dioClient.dio.get(
        '/rest/v1/expenses',
        queryParameters: {
          'select': '*',
          'order': 'expense_date.desc',
        },
      );
      
      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load expenses');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<void> createExpense(Expense expense) async {
    try {
      await _dioClient.dio.post(
        '/rest/v1/expenses',
        data: expense.toJson(),
        options: Options(headers: {'Prefer': 'return=minimal'}), // optimization
      );
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to create expense');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _dioClient.dio.patch(
        '/rest/v1/expenses',
        queryParameters: {'id': 'eq.${expense.id}'},
        data: expense.toJson(),
      );
    } on DioException catch (e) {
      // Supabase 404 implies RLS blocked it or not found
      throw ServerFailure(e.message ?? 'Failed to update expense');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dioClient.dio.delete(
        '/rest/v1/expenses',
        queryParameters: {'id': 'eq.$id'},
      );
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to delete expense');
    }
  }
}
